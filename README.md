# OliveOilAnalyser 
 
**Olive Oil Quality Analysis with NIR Spectroscopy ** 
 
- **Institution:** UM6P - Foundation Mascir
- **Platform:** Flutter (Android) 
- **Database:** PostgreSQL (remote) + SQLite (local/offline) 
 
## Features 
- Bluetooth NIR spectrometer connection 
- Real-time spectral acquisition (400-2500nm) 
- Offline-first with cloud sync 
- Dashboard, history, ML model management 
 
## Quick Start 
 
### Backend 
```bash 
cd backend 
copy .env.example .env 
docker-compose up --build 
``` 
 
### Frontend 
```bash 
cd frontend 
flutter pub get 
flutter run 
``` 
 
## Documentation 
- [Cahier des Charges](docs/cahier-des-charges.md) 
- [Architecture Technique](docs/architecture-technique.md) 
- [API Specifications](docs/api-specifications.md) 
- [Database Schema](docs/database-schema.md) 
- [Bluetooth Protocol](docs/bluetooth-protocol.md) 
 
## Authors 
- Ahlam EL BECHARI 