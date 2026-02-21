# UI Guide: Displaying Animal Images

## How image URLs work

Every animal object in the API includes an `imageUrl` field:

```json
{
  "id": 1,
  "name": "Cane",
  "imageUrl": "/static/images/Dog.png",
  "guessed": false
}
```

This is a **relative path** served by the backend. To build the full URL, prepend the backend base URL:

```
Full URL = <BASE_URL> + imageUrl
Example:  https://api.example.com/static/images/Dog.png
```

## Handling missing images

Not all 120 animals have images yet (50 of 120 currently have images). When an image is not available, `imageUrl` is `null`:

```json
{
  "id": 35,
  "name": "Topo",
  "imageUrl": null,
  "guessed": false
}
```

The client **must** check for `null` and show a placeholder. Suggested approach:

```dart
Image _buildAnimalImage(String? imageUrl) {
  if (imageUrl == null) {
    return Image.asset('assets/images/placeholder_animal.png');
  }
  return Image.network('$baseUrl$imageUrl');
}
```

## Animals with images (50/120)

Images are available for animals across all levels. The API is the source of truth — if `imageUrl` is non-null, the image exists and is served at that path.

## Image format

- Format: PNG with transparent background
- Naming: Title case with underscores (e.g., `Dog.png`, `Red_Panda.png`, `Aye-Aye.png`)
- Served from: `/static/images/`

## Endpoints that return `imageUrl`

| Endpoint | Field path |
|---|---|
| `GET /api/v1/levels` | `levels[].animals[].imageUrl` |
| `GET /api/v1/levels/{id}` | `animals[].imageUrl` |
| `GET /api/v1/users/me/progress` | `levels.{id}[].imageUrl` |
