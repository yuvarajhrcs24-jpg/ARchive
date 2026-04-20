# ARchive

A minimal location-based smart tour guide web app prototype with:

- Nearby place discovery by category (Historical, Food, Nature, Temples)
- Search and near-me filtering
- Place details (images, descriptions, hours, rating)
- Audio guide (manual play + nearby autoplay)
- Navigation via Google Maps routes
- Saved places and day-wise trip planning with stop reordering
- Offline city data download (places, images, audio) using cache + service worker
- Profile settings (language selection and demo login state)

## Run locally

```bash
cd /home/runner/work/ARchive/ARchive
python -m http.server 8000
```

Open: `http://127.0.0.1:8000`
