const APP_STORAGE_KEY = "archive-smart-tour";
const TRIP_STORAGE_KEY = "archive-trips";
const OFFLINE_CACHE = "archive-offline-city-data-v1";
const MIN_TRAVEL_TIME_MINS = 5;
const AVERAGE_SPEED_KMH = 30;
const MINS_PER_HOUR = 60;

const state = {
  userLocation: null,
  places: [],
  filteredCategory: "All",
  searchQuery: "",
  activePlace: null,
  saved: JSON.parse(localStorage.getItem(APP_STORAGE_KEY) || "[]"),
  trips: JSON.parse(localStorage.getItem(TRIP_STORAGE_KEY) || "{}"),
  language: localStorage.getItem("archive-language") || "English",
};

const categories = ["All", "Historical", "Food", "Nature", "Temples"];
const screens = document.querySelectorAll(".screen");
const tabs = document.querySelectorAll(".tabs button");
const searchInput = document.getElementById("searchInput");
const categoriesWrap = document.getElementById("categories");
const nearbyPlaces = document.getElementById("nearbyPlaces");
const popularPlaces = document.getElementById("popularPlaces");
const mapPins = document.getElementById("mapPins");
const mapCanvas = document.getElementById("mapCanvas");
const userLocationEl = document.getElementById("userLocation");
const savedPlacesEl = document.getElementById("savedPlaces");
const tripStopsEl = document.getElementById("tripStops");
const tripDayInput = document.getElementById("tripDay");
const detailScreen = document.getElementById("placeDetail");
const detailName = document.getElementById("detailName");
const detailImage = document.getElementById("detailImage");
const detailShort = document.getElementById("detailShort");
const detailLong = document.getElementById("detailLong");
const detailHours = document.getElementById("detailHours");
const detailRating = document.getElementById("detailRating");
const playGuideBtn = document.getElementById("playGuide");
const navigateBtn = document.getElementById("navigateBtn");
const saveBtn = document.getElementById("saveBtn");
const languageSelect = document.getElementById("languageSelect");
const authStatus = document.getElementById("authStatus");
let mapInstance;
let mapMarkers = [];

function showScreen(id) {
  screens.forEach((screen) => screen.classList.toggle("active", screen.id === id));
  tabs.forEach((tab) => tab.classList.toggle("active", tab.dataset.screen === id));
}

function toRad(value) {
  return (value * Math.PI) / 180;
}

function getDistanceKm(lat1, lon1, lat2, lon2) {
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
  return R * (2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a)));
}

function estimateTravelTime(distanceKm) {
  const mins = Math.max(MIN_TRAVEL_TIME_MINS, Math.round((distanceKm / AVERAGE_SPEED_KMH) * MINS_PER_HOUR));
  return `${mins} min`;
}

function isSaved(placeId) {
  return state.saved.includes(placeId);
}

function persistSaved() {
  localStorage.setItem(APP_STORAGE_KEY, JSON.stringify(state.saved));
}

function persistTrips() {
  localStorage.setItem(TRIP_STORAGE_KEY, JSON.stringify(state.trips));
}

function filteredPlaces() {
  return state.places
    .map((place) => {
      const distance = state.userLocation
        ? getDistanceKm(state.userLocation.lat, state.userLocation.lng, place.lat, place.lng)
        : null;
      return { ...place, distance };
    })
    .filter((place) => {
      const categoryMatch = state.filteredCategory === "All" || place.category === state.filteredCategory;
      const query = state.searchQuery.trim().toLowerCase();
      const queryMatch =
        !query ||
        place.name.toLowerCase().includes(query) ||
        place.category.toLowerCase().includes(query) ||
        place.shortDescription.toLowerCase().includes(query);
      const nearbyMatch = place.distance === null || place.distance <= 25;
      return categoryMatch && queryMatch && nearbyMatch;
    })
    .sort((a, b) => (a.distance || 999) - (b.distance || 999));
}

function placeCard(place) {
  const template = document.getElementById("placeCardTemplate");
  const node = template.content.cloneNode(true);
  node.querySelector(".card-image").src = place.image;
  node.querySelector(".card-title").textContent = place.name;
  node.querySelector(".card-subtitle").textContent = place.shortDescription;
  const distanceText = place.distance ? `${place.distance.toFixed(1)} km` : "Distance unavailable";
  const eta = place.distance ? estimateTravelTime(place.distance) : "-";
  node.querySelector(".card-meta").textContent = `${place.category} • ${distanceText} • ${eta}`;

  node.querySelector(".preview-btn").addEventListener("click", () => openDetails(place.id));
  node.querySelector(".navigate-btn").addEventListener("click", () => openNavigation(place));
  return node;
}

function renderLists() {
  const places = filteredPlaces();
  nearbyPlaces.innerHTML = "";
  mapPins.innerHTML = "";

  places.forEach((place) => {
    nearbyPlaces.appendChild(placeCard(place));
    mapPins.appendChild(placeCard(place));
  });

  popularPlaces.innerHTML = "";
  state.places
    .slice()
    .sort((a, b) => b.rating - a.rating)
    .slice(0, 3)
    .forEach((place) => popularPlaces.appendChild(placeCard(place)));

  renderSaved();
  renderMap(places);
}

function renderCategories() {
  categoriesWrap.innerHTML = "";
  categories.forEach((category) => {
    const chip = document.createElement("button");
    chip.textContent = category;
    if (category === state.filteredCategory) chip.style.background = "#bfdbfe";
    chip.addEventListener("click", () => {
      state.filteredCategory = category;
      renderCategories();
      renderLists();
    });
    categoriesWrap.appendChild(chip);
  });
}

function openDetails(placeId) {
  const place = state.places.find((p) => p.id === placeId);
  if (!place) return;
  state.activePlace = place;
  detailName.textContent = place.name;
  detailImage.src = place.image;
  detailShort.textContent = place.shortDescription;
  detailLong.textContent = place.detailedDescription;
  detailHours.textContent = place.openingHours;
  detailRating.textContent = `${place.rating} / 5`;
  saveBtn.textContent = isSaved(place.id) ? "Saved" : "Save";
  showScreen("placeDetail");
}

function openNavigation(place) {
  const origin = state.userLocation ? `${state.userLocation.lat},${state.userLocation.lng}` : "Current+Location";
  window.open(
    `https://www.google.com/maps/dir/?api=1&origin=${encodeURIComponent(origin)}&destination=${place.lat},${place.lng}&travelmode=driving`,
    "_blank"
  );
}

function toggleSave(placeId) {
  if (isSaved(placeId)) {
    state.saved = state.saved.filter((id) => id !== placeId);
  } else {
    state.saved.push(placeId);
  }
  persistSaved();
  renderSaved();
}

function addToTrip(placeId) {
  const day = tripDayInput.value.trim() || "Day 1";
  const current = state.trips[day] || [];
  if (!current.includes(placeId)) {
    state.trips[day] = [...current, placeId];
    persistTrips();
  }
  renderSaved();
}

function moveTripStop(day, placeId, direction) {
  const list = state.trips[day] || [];
  const index = list.indexOf(placeId);
  if (index < 0) return;
  const target = index + direction;
  if (target < 0 || target >= list.length) return;
  [list[index], list[target]] = [list[target], list[index]];
  state.trips[day] = [...list];
  persistTrips();
  renderSaved();
}

function renderSaved() {
  savedPlacesEl.innerHTML = "";
  const savedPlaces = state.places.filter((place) => isSaved(place.id));
  if (savedPlaces.length === 0) {
    savedPlacesEl.textContent = "No saved places yet.";
  } else {
    savedPlaces.forEach((place) => {
      const wrapper = document.createElement("div");
      wrapper.className = "card";
      const image = document.createElement("img");
      image.className = "card-image";
      image.src = place.image;
      image.alt = place.name;
      const content = document.createElement("div");
      const title = document.createElement("h3");
      title.className = "card-title";
      title.textContent = place.name;
      const subtitle = document.createElement("p");
      subtitle.className = "card-subtitle";
      subtitle.textContent = place.category;
      content.append(title, subtitle);
      wrapper.append(image, content);

      const controls = document.createElement("div");
      controls.className = "card-actions";
      const openBtn = document.createElement("button");
      openBtn.textContent = "Details";
      openBtn.addEventListener("click", () => openDetails(place.id));
      const tripBtn = document.createElement("button");
      tripBtn.textContent = "Add to Trip";
      tripBtn.addEventListener("click", () => addToTrip(place.id));
      controls.append(openBtn, tripBtn);
      content.appendChild(controls);
      savedPlacesEl.appendChild(wrapper);
    });
  }

  tripStopsEl.innerHTML = "";
  Object.entries(state.trips).forEach(([day, placeIds]) => {
    if (!placeIds.length) return;
    const section = document.createElement("section");
    const dayHeading = document.createElement("h3");
    dayHeading.textContent = day;
    section.appendChild(dayHeading);
    placeIds.forEach((id) => {
      const place = state.places.find((p) => p.id === id);
      if (!place) return;
      const row = document.createElement("div");
      row.className = "card-actions";
      const name = document.createElement("span");
      name.textContent = place.name;
      const up = document.createElement("button");
      up.textContent = "↑";
      up.addEventListener("click", () => moveTripStop(day, id, -1));
      const down = document.createElement("button");
      down.textContent = "↓";
      down.addEventListener("click", () => moveTripStop(day, id, 1));
      row.append(name, up, down);
      section.appendChild(row);
    });
    tripStopsEl.appendChild(section);
  });
}

function ensureMap() {
  if (mapInstance || typeof L === "undefined") return;
  mapInstance = L.map(mapCanvas).setView([12.9716, 77.5946], 11);
  L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    maxZoom: 19,
    attribution: "&copy; OpenStreetMap contributors",
  }).addTo(mapInstance);
}

function renderMap(places) {
  ensureMap();
  if (!mapInstance) return;
  mapMarkers.forEach((marker) => marker.remove());
  mapMarkers = places.map((place) => {
    const marker = L.marker([place.lat, place.lng]).addTo(mapInstance);
    marker.bindPopup(`<strong>${place.name}</strong><br/>${place.shortDescription}`);
    marker.on("click", () => openDetails(place.id));
    return marker;
  });

  if (state.userLocation) {
    mapInstance.setView([state.userLocation.lat, state.userLocation.lng], 12);
  } else if (places.length) {
    mapInstance.setView([places[0].lat, places[0].lng], 11);
  }
}

function playGuide(place) {
  const selectedLanguage = languageSelect.value;
  const message = place.languages[selectedLanguage] || place.languages.English || place.shortDescription;
  const playFallbackAudio = () => {
    const fallbackAudio = new Audio(place.audio);
    fallbackAudio.play().catch(() => {
      // Browser may block autoplay or unsupported codec in sandbox.
    });
  };

  if ("speechSynthesis" in window && "SpeechSynthesisUtterance" in window) {
    const utter = new SpeechSynthesisUtterance(message);
    utter.onerror = () => playFallbackAudio();
    speechSynthesis.cancel();
    speechSynthesis.speak(utter);
    return;
  }

  playFallbackAudio();
}

function maybeAutoplayNearbyGuide() {
  if (!state.userLocation || !state.places.length) return;
  const nearest = filteredPlaces()[0];
  if (nearest?.distance !== undefined && nearest.distance <= 0.3) {
    playGuide(nearest);
  }
}

async function loadPlaces() {
  const response = await fetch("data/places.json");
  state.places = await response.json();
  renderCategories();
  renderLists();
  maybeAutoplayNearbyGuide();
}

function detectLocation() {
  if (!navigator.geolocation) {
    userLocationEl.textContent = "Geolocation unavailable.";
    return;
  }

  navigator.geolocation.getCurrentPosition(
    (position) => {
      state.userLocation = {
        lat: position.coords.latitude,
        lng: position.coords.longitude,
      };
      userLocationEl.textContent = `Current location: ${state.userLocation.lat.toFixed(4)}, ${state.userLocation.lng.toFixed(4)}`;
      renderLists();
      maybeAutoplayNearbyGuide();
    },
    () => {
      userLocationEl.textContent = "Location permission denied. Showing general results.";
      renderLists();
    }
  );
}

async function downloadOfflineData() {
  if (!("caches" in window)) {
    alert("Offline caching is not supported in this browser.");
    return;
  }

  const cache = await caches.open(OFFLINE_CACHE);
  const assets = [
    "./",
    "index.html",
    "styles.css",
    "app.js",
    "manifest.webmanifest",
    "data/places.json",
    ...state.places.flatMap((place) => [place.image, place.audio]),
  ];
  await cache.addAll(assets);
  alert("City data downloaded for offline use.");
}

function registerServiceWorker() {
  if ("serviceWorker" in navigator) {
    navigator.serviceWorker.register("service-worker.js");
  }
}

function wireEvents() {
  tabs.forEach((tab) => {
    tab.addEventListener("click", () => showScreen(tab.dataset.screen));
  });

  searchInput.addEventListener("input", () => {
    state.searchQuery = searchInput.value;
    renderLists();
  });

  document.getElementById("backToHome").addEventListener("click", () => showScreen("home"));
  playGuideBtn.addEventListener("click", () => state.activePlace && playGuide(state.activePlace));
  navigateBtn.addEventListener("click", () => state.activePlace && openNavigation(state.activePlace));
  saveBtn.addEventListener("click", () => {
    if (!state.activePlace) return;
    toggleSave(state.activePlace.id);
    saveBtn.textContent = isSaved(state.activePlace.id) ? "Saved" : "Save";
  });

  document.getElementById("downloadOffline").addEventListener("click", downloadOfflineData);
  document.getElementById("googleLogin").addEventListener("click", () => {
    authStatus.textContent = "Logged in (demo)";
  });

  languageSelect.value = state.language;
  languageSelect.addEventListener("change", () => {
    state.language = languageSelect.value;
    localStorage.setItem("archive-language", state.language);
  });
}

wireEvents();
registerServiceWorker();
loadPlaces().then(detectLocation);
