# Product Management App - Bloc + Dio

A Flutter application that performs full CRUD (Create, Read, Update, Delete) operations on product data using the **FakeStore API**. Built with **flutter_bloc** state management and **dio** package for networking.

Note: This project and the companion Provider/HTTP project both use the same public API (https://fakestoreapi.com); they differ in UI and in the chosen state-management/network libraries.

## Tech Stack

- **Flutter** - UI Framework
- **flutter_bloc** (^8.1.0) - State Management
- **dio** (^5.4.0) - Network Requests
- **equatable** (^2.0.5) - Value equality
- **FakeStore API** - Public REST API for e-commerce products

## API Information

**Base URL:** `https://fakestoreapi.com`

**Endpoints:**
- `GET /products` - List all products
- `GET /products/{id}` - Get single product details
- `POST /products` - Create a new product
- `PUT /products/{id}` - Update a product
- `DELETE /products/{id}` - Delete a product
- `GET /products/categories` - Get all categories
- `GET /products/category/{category}` - Get products by category

