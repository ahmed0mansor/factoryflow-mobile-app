# FactoryFlow Mobile

A Flutter mobile app for **small factory inventory, attendance, and stock movement tracking**.

## Value

This project demonstrates:

- Mobile dashboard design
- Inventory management logic
- Low-stock alerts
- Staff attendance tracking
- Stock in/out movements
- Practical business workflow modeling

## Screens

- Operations Dashboard
- Inventory
- Staff Attendance
- Stock Movements

## Run

```bash
flutter pub get
flutter run -d chrome
```

To generate native Android/iOS platform folders:

```bash
flutter create . --platforms=android,ios,web
flutter run
```

## Future Improvements

- Local database using Hive or SQLite
- User authentication
- Export reports to PDF/Excel
- Role-based access control
