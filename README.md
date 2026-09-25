# Lab Activity 2: Discussion

### Model, Service, and Screen Interaction

This activity follows the Model–Service–Screen architecture, which separates the application's data, business logic, and user interface into different layers. This design makes the application easier to understand, maintain, and expand.

The **Model** represents the structure of the data received from the API. It defines the attributes of an object and provides methods to convert JSON data into Dart objects and vice versa. Instead of working directly with raw JSON, the application uses model objects, making the code cleaner and more organized.

The **Service** layer is responsible for communicating with the API. It sends HTTP requests to the API endpoint, receives the server's response, and converts the JSON response into model objects. The service acts as the bridge between the application and the external data source, keeping networking code separate from the user interface.

The **Screen** serves as the presentation layer. It calls the appropriate service methods to request data from the API. Once the service returns the model objects, the screen updates its state and displays the information to the user using Flutter widgets such as `ListView`, `Card`, or `GridView`. This separation ensures that the UI focuses on presenting data rather than handling API communication.

The interaction between these components follows this sequence:

1. The user opens the screen or performs an action.
2. The screen calls a method from the service layer.
3. The service sends an HTTP request to the API endpoint.
4. The API returns a JSON response.
5. The service converts the JSON into model objects.
6. The model objects are returned to the screen.
7. The screen rebuilds the UI and displays the retrieved data.

The general workflow can be summarized as:

**Screen → Service → API → Model → Screen**

### Design Pattern

This activity introduces a layered design pattern based on the Model–Service–Screen architecture. By separating data models, API services, and UI screens into different files, the application becomes more modular, reusable, and easier to debug.

Future enhancements, such as adding new API endpoints or modifying the user interface, can be implemented with minimal changes to the other layers. This results in a more scalable and maintainable application structure.

---

# Lab Activity 3: Discussion

### Cart Model, Service, and Screen Interaction

In this laboratory activity, the cart functionality follows the Model–Service–Screen structure introduced in the previous activity. The **Cart Model** represents the cart data received from the DummyJSON API, including the user, products, quantities, prices, and other cart-related information.

The **ProductService** is responsible for communicating with the DummyJSON API and retrieving the required cart and product information. Instead of allowing the Cart screen to directly perform HTTP requests, the screen requests the required data through the service.

The **CartScreen** is responsible for presenting the retrieved cart information to the user. It uses the data provided by the service and model to display the products, quantities, prices, and order summary.

The interaction can be summarized as:

**CartScreen → ProductService → DummyJSON Cart API → Cart Model → CartScreen**

When a user selects a product from the cart, the product ID of the selected item is used to retrieve its complete product information. The retrieved product is then passed to the same `ProductDetailsScreen` that is also used by the Product screen.

The navigation flow can be summarized as:

**Cart Item → Product ID → ProductService → Get Product by ID → ProductDetailsScreen**

Using the same `ProductDetailsScreen` provides a consistent product-detail interface regardless of whether the product was selected from the Product screen or the Cart screen. It also avoids creating a separate details screen specifically for cart products.

### Updated Design Pattern

The updated design continues to use the Model–Service–Screen architecture while improving the reusability and organization of the application. The model represents the data received from the API, the service handles API communication and data retrieval, and the screen focuses on displaying information and handling user interaction.

The basic structure can be summarized as:

**Screen → Service → API → Model → Screen**

An important improvement in this activity is the reuse of `ProductDetailsScreen`. The Product screen can open the details of a product using the product information retrieved from the product list. Meanwhile, the Cart screen can use the product ID of a cart item to retrieve the complete product information before opening the same details screen.

This approach reduces duplicate code and keeps the product details interface consistent throughout the application. It also makes the application easier to maintain because changes made to `ProductDetailsScreen` can be applied to both the Product and Cart screens.

### Using Get by ID from the Cart

The Cart API returns information about the products associated with a user's cart. Each cart item contains a product ID that identifies the corresponding product. This ID can be used to retrieve the complete information of a specific product.

When a user selects an item from the cart, the product ID is passed to the `fetchProductById()` method:

```dart
final product = await _productService.fetchProductById(
  cartItem.id,
);
```

The service uses the product ID to retrieve the complete product information. After the product has been retrieved, it can be passed to the existing `ProductDetailsScreen`:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProductDetailsScreen(
      product: product,
      showAddToCart: false,
    ),
  ),
);
```

The overall process can be summarized as:

**Get User Cart → Select Cart Item → Get Product ID → Fetch Product by ID → ProductDetailsScreen**

Using Get by ID allows the Cart screen to obtain the complete product information required by the details screen while still reusing the existing `ProductDetailsScreen`.

---

# Lab Activity 4: Discussion

### User Model, Services, and Profile Screen Interaction

In this laboratory activity, the application uses the **User Model**, **UserService**, and screens together to handle and display user data from the DummyJSON API.

When the user enters a username and password on the Sign In screen, the credentials are passed to the `loginUser()` method of `UserService`. The service sends the authentication request to the DummyJSON API and receives the authenticated user's data when the credentials are valid.

The returned JSON data is converted into a `User` object using the `User.fromJson()` factory constructor. Important user information such as the user ID, username, email, first name, last name, gender, image, access token, and refresh token is then saved locally using `SharedPreferences`.

The Profile screen retrieves the saved user information through `UserService`. The saved data is converted back into a `User` object and displayed on the Profile screen. This allows the application to display the currently authenticated user's information without hard-coding the values or requesting the same information every time the Profile screen is opened.

The interaction can be summarized as:

**Sign In Screen → UserService → DummyJSON API → User Model → SharedPreferences → Profile Screen**

### Updated Design Pattern

The updated design pattern separates the application into **models, services, providers, screens, and widgets**.

The model represents the structure of data received from the API. For example, `User` represents authenticated user information, while `Product` represents product information.

The service layer is responsible for communicating with the API and handling data operations. `UserService` handles authentication and saved user information, while `ProductService` handles product and cart-related API requests.

Screens are responsible for presenting information and handling user interaction. Examples include the Sign In, Splash, Home, Product, Cart, and Profile screens.

Providers are used for application state that needs to be shared or updated across widgets. For example, `ThemeProvider` manages the application's light and dark themes, while `CartProvider` manages the current cart state.

`SharedPreferences` is used for persistent user authentication and user information so that the data remains available even when the application is restarted.

The updated structure can be summarized as:

**API → Services → Models → Providers/Saved Data → Screens → Widgets**

This design separates the responsibilities of the application and makes the source code easier to organize, maintain, and update.

### Rendering the Cart Screen Using the Saved User ID

After a successful login, the authenticated user's ID is saved in `SharedPreferences` together with the other user information. When the Home screen is loaded, `UserService.getUser()` retrieves the saved information and converts it into a `User` object.

The saved `user.id` is then passed to the Cart screen instead of using a hard-coded user ID:

```dart
CartScreen(
  userId: _user!.id,
)
```

The Cart screen can use this ID when retrieving the cart associated with the authenticated user. This allows the application to render the cart according to the account that is currently logged in.

The process can be summarized as:

**Login → Save User Data → Retrieve Saved User → Get User ID → CartScreen(userId) → User Cart**

This implementation connects authentication with the Profile and Cart screens. The Profile screen displays the information of the authenticated user, while the Cart screen uses the same saved user's ID to determine which user's cart data should be rendered.

---

# Lab Activity 5: Discussion

### DummyJSON and Firebase Authentication Workflow

In this laboratory activity, the application was enhanced to support two authentication methods: **DummyJSON** and **Firebase Authentication**. The Sign In screen allows the user to select which authentication method will be used.

For **DummyJSON**, the user signs in using a username and password. The credentials are passed to the `UserService`, which communicates with the DummyJSON API. Once the login is successful, the returned user information and authentication data are saved locally, and the user is redirected to the Home screen.

For **Firebase**, the user signs in using an email address and password. The credentials are processed through Firebase Authentication using the `UserService`.

If the user does not have an existing Firebase account, the Sign Up screen allows the user to register by providing the required information, including first name, last name, age, contact number, username, email address, and password. After validation, a Firebase account is created, the username is updated, and the additional user information is saved for use within the application.

The general authentication workflow can be summarized as:

**Sign In → Select DummyJSON or Firebase → Validate Credentials → Authenticate User → Load User Information → Home Screen**

For a new Firebase user, the workflow is:

**Sign In → Sign Up → Enter User Information → Validate Form → Create Firebase Account → Save User Information → Home Screen**

### UserService Implementation

The main idea of the `UserService` implementation is to separate authentication and user-management logic from the user interface.

Instead of placing API requests and Firebase operations directly inside the screens, the application uses `UserService` as the central location for handling user-related operations.

For **DummyJSON**, the service handles user login and the storage and retrieval of user information.

For **Firebase**, the service handles operations such as signing in, creating an account, signing out, updating the username, changing the password, and deleting an account.

The basic structure of the implementation can be summarized as:

**User Interface → UserService → DummyJSON API / Firebase Authentication**

This approach keeps the screen files focused on displaying the interface, validating user input, and handling navigation. It also makes the code more organized and reusable because different screens can access the same user-related functions through `UserService`.

### Benefits of Firebase Implementation

The integration of Firebase improves the Flutter application by providing an actual authentication system in addition to the DummyJSON API used in the previous implementation.

Unlike the predefined accounts provided by DummyJSON, Firebase allows users to create and manage their own accounts within the application.

Firebase Authentication also provides several account-management features used in this laboratory, including user registration, email and password authentication, username updates, password changes, account deletion, and sign-out functionality.

These features make the authentication process more realistic and demonstrate how user accounts can be managed in a Flutter application.

Another benefit is that Firebase authentication is handled separately from the application's UI through the `UserService`. This allows the application to support both DummyJSON and Firebase without placing all authentication logic directly inside the Sign In, Sign Up, and Profile screens.

Overall, this laboratory activity demonstrated how the existing Flutter application can be enhanced from using predefined API users to supporting user registration and account management through Firebase. It also demonstrated the importance of separating the user interface, service layer, and authentication provider to maintain a cleaner and more manageable application structure.
