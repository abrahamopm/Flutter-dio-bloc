# Product Management App - Bloc + Dio

| Name | ID | Section |
| :--- | :--- | :--- |
| Abraham Nigatu Kebede | UGR/7532/16 | 2 |

A Flutter application that performs full CRUD operations on product data using the **FakeStore API**. Built with **flutter_bloc** state management and the **dio** package for networking.

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

## Screenshots

### Home Screen

| Home Page |
| :---: |
| <img src="screenshots/home_screen.png" width="350" alt="Home Page"> |
| Main feed displaying the product list, category filtering, and loading state. |

### Create Product (POST)

| Create UI | Input Validation | Success Response |
| :---: | :---: | :---: |
| <img src="screenshots/POST_request.png" width="250" alt="POST Request UI"> | <img src="screenshots/POST_request_input_validation.png" width="250" alt="POST Request Validation"> | <img src="screenshots/POST_request_success.png" width="250" alt="POST Request Success"> |
| Entry form for new products. | Form-field validation messages. | Success prompt after POST request execution. |

### Update Product (PUT / PATCH)

| PUT Request UI | PUT Success | PATCH Request UI | PATCH Success |
| :---: | :---: | :---: | :---: |
| <img src="screenshots/PUT_request_UI.png" width="180" alt="PUT Request UI"> | <img src="screenshots/PUT_request_success.png" width="180" alt="PUT Request Success"> | <img src="screenshots/PATCH_request_UI.png" width="180" alt="PATCH Request UI"> | <img src="screenshots/PATCH_request_success.png" width="180" alt="PATCH Request Success"> |
| Pre-filled form for complete resource updates. | Success dialog for PUT request. | Form to edit selected fields (partial update). | Success dialog for PATCH request. |

### Delete Product (DELETE)

| Delete Confirmation | Delete Success |
| :---: | :---: |
| <img src="screenshots/DELETE_request.png" width="250" alt="DELETE Request UI"> | <img src="screenshots/DELETE_success.png" width="250" alt="DELETE Request Success"> |
| Confirmation prompt before deletion. | Success notification confirming simulated deletion. |

