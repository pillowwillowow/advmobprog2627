
# Lab Activity 2: Discussion

This activity follows the Model–Service–Screen architecture, which separates the application's data, business logic, and user interface into different layers. This design makes the application easier to understand, maintain, and expand.

The Model represents the structure of the data received from the API. It defines the attributes of an object and provides methods to convert JSON data into Dart objects and vice versa. Instead of working directly with raw JSON, the application uses model objects, making the code cleaner and more organized.

The Service layer is responsible for communicating with the API. It sends HTTP requests to the API endpoint, receives the server's response, and converts the JSON response into model objects. The service acts as the bridge between the application and the external data source, keeping networking code separate from the user interface.

The Screen serves as the presentation layer. It calls the appropriate service methods to request data from the API. Once the service returns the model objects, the screen updates its state and displays the information to the user using Flutter widgets such as `ListView`, `Card`, or `GridView`. This separation ensures that the UI focuses only on presenting data rather than handling API communication.

The interaction between these components follows this sequence:

1. The user opens the screen or performs an action.
2. The screen calls a method from the service layer.
3. The service sends an HTTP request to the API endpoint.
4. The API returns a JSON response.
5. The service converts the JSON into model objects.
6. The model objects are returned to the screen.
7. The screen rebuilds the UI and displays the retrieved data.

This activity introduces a layered design pattern based on the Model–Service–Screen architecture, which is commonly used in Flutter applications. By separating data models, API services, and UI screens into different files, the application becomes more modular, reusable, and easier to debug. Future enhancements, such as adding new API endpoints or modifying the user interface, can be implemented with minimal changes to the other layers, resulting in a more scalable and maintainable application.

## Lab Activity 3 Discussion:

### Interaction of the Cart Model, Service, and Screen

In this laboratory activity, the cart functionality was implemented by separating the data model, API service, and user interface into different parts of the application. These components work together to retrieve cart information from the API and display it on the Cart screen.

The **Cart Model** represents the structure of the cart data received from the API. It contains the information needed by the application, such as the cart ID, user ID, products, quantity, price, and other cart-related values. The model converts the JSON response from the API into Dart objects that can be accessed more easily by the application.

The **ProductService** is responsible for communicating with the DummyJSON API. Instead of allowing the Cart screen to directly perform HTTP requests, the screen requests the required data through the service. The service retrieves the cart associated with a user and converts the API response into the appropriate model.

The **CartScreen** is responsible for presenting the retrieved cart information to the user. It uses the data provided by the service and model to display the products, quantities, prices, and order summary. This separation prevents the screen from containing unnecessary API and data-processing logic.

The general interaction can be represented as:

**CartScreen → ProductService → DummyJSON Cart API → Cart Model → CartScreen**

When a user selects a product from the cart, the application can retrieve the complete product information using its product ID and open the same `product_details_screen.dart` that is also used by the Product screen. This avoids creating a separate detail screen specifically for cart products.

The navigation flow can therefore be summarized as:

**Cart Item → Product ID → ProductService → Get Product by ID → ProductDetailsScreen**

Using the same `ProductDetailsScreen` provides a consistent product-detail interface regardless of whether the product was selected from the main product list or from the user's cart.

### Updated Design Pattern

The updated design in this activity improves the separation of responsibilities between the different parts of the application. The **model** defines the structure of the data, the **service** manages communication with the API, and the **screen** focuses on displaying the data and handling user interaction.

The basic structure follows:

**Screen → Service → API → Model → Screen**

This design makes the application more organized compared with placing the HTTP request, JSON conversion, and interface code inside a single screen. It also improves reusability because the same service methods and models can be accessed by multiple screens.

Another improvement is the reuse of `ProductDetailsScreen`. Both the Product screen and Cart screen can navigate to the same product details page. The difference is the source of the selected product. The Product screen already has product information from the product listing, while the Cart screen can use the product ID from the cart to retrieve the complete product information before opening the details page.

This approach reduces duplicate code and keeps the application's product-related functionality consistent.

### Using Get by ID in the Cart Endpoint

The cart API provides information about the products included in a user's cart. Each cart product contains an ID that identifies the corresponding product. This ID can be used to retrieve the complete product information through the product service.

For example, when a cart item is selected, its product ID can be passed to the `fetchProductById()` method:

```dart
final product = await _productService.fetchProductById(
  cartItem.id,
);

## Lab Activity 4: Discussion

### User Model, Services, and Profile Screen Interaction

The application uses the User model, UserService, and screens together to handle and display user data from the DummyJSON API. When the user enters a username and password on the Sign In screen, the credentials are passed to the `loginUser()` method of `UserService`. The service sends the request to the authentication API endpoint and receives the authenticated user's data when the credentials are valid.

The returned JSON data is converted into a `User` object using the `User.fromJson()` factory constructor. Important user information such as the user ID, username, email, first name, last name, gender, image, access token, and refresh token is then saved locally using SharedPreferences.

The Profile screen retrieves the saved user information through `UserService`. The saved data is converted back into a `User` object and displayed on the Profile screen. This allows the application to show the currently authenticated user's information without hard-coding the values or requesting the same information every time the Profile screen is opened.

The interaction can be summarized as:

Sign In Screen → UserService → DummyJSON API → User Model → SharedPreferences → Profile Screen

### Updated Design Pattern

The updated design pattern separates the application into models, services, providers, screens, and widgets. The model represents the structure of data received from the API. For example, `User` represents authenticated user information, while `Product` represents product information.

The service layer is responsible for communicating with the API and handling data operations. `UserService` handles authentication and saved user information, while `ProductService` handles product and cart-related API requests. Screens are responsible for presenting information and handling user interaction. Examples include the Sign In, Splash, Home, Product, Cart, and Profile screens.

Providers are used for application state that needs to be shared or updated across widgets. For example, `ThemeProvider` manages the application's light and dark themes, while `CartProvider` manages the current cart state. SharedPreferences is used for persistent user authentication and user information so that the data remains available even when the application is restarted.

This design pattern separates the responsibilities of the application and makes the source code easier to organize, maintain, and update.

The updated structure can be summarized as:

API → Services → Models → Providers/Saved Data → Screens → Widgets

### Rendering the Cart Screen Using the Saved User ID

After a successful login, the authenticated user's ID is saved in SharedPreferences together with the other user information. When the Home screen is loaded, `UserService.getUser()` retrieves the saved information and converts it into a `User` object.

The saved `user.id` is then passed to the Cart screen instead of using a hard-coded user ID. For example:

`CartScreen(userId: _user!.id)`

The Cart screen can use this ID when retrieving the cart associated with the authenticated user. This allows the application to render the cart according to the account that is currently logged in.

The process can be summarized as:

Login → Save User Data → Retrieve Saved User → Get User ID → CartScreen(userId) → User Cart

This implementation connects authentication with the Profile and Cart screens. The Profile screen displays the information of the authenticated user, while the Cart screen uses the same saved user's ID to determine which user's cart data should be rendered.

## Lab Activity 5 Discussion:

### DummyJSON and Firebase Authentication Workflow

In this laboratory activity, the application was enhanced to support two authentication methods: **DummyJSON** and **Firebase Authentication**. The Sign In screen allows the user to select which authentication method will be used.

For **DummyJSON**, the user signs in using a username and password. The credentials are passed to the `UserService`, which communicates with the DummyJSON API. Once the login is successful, the returned user information and authentication data are saved locally and the user is redirected to the Home screen.

For **Firebase**, the user signs in using an email address and password. The credentials are processed through Firebase Authentication using the `UserService`. If the user does not have an existing Firebase account, the Sign Up screen allows the user to register by providing the required information, such as first name, last name, age, contact number, username, email address, and password. After validation, a Firebase account is created, the username is updated, and the additional user information is saved for use within the application.

The general authentication workflow can be summarized as:

**Sign In → Select DummyJSON or Firebase → Validate Credentials → Authenticate User → Load User Information → Home Screen**

For a new Firebase user, the workflow is:

**Sign In → Sign Up → Enter User Information → Validate Form → Create Firebase Account → Save User Information → Home Screen**

### UserService Implementation

The main idea of the `UserService` implementation is to separate the authentication and user-management logic from the user interface. Instead of placing API requests and Firebase operations directly inside the screens, the application uses `UserService` as the central location for handling user-related operations.

For DummyJSON, the service handles user login and the storage and retrieval of user information. For Firebase, it handles operations such as signing in, creating an account, signing out, updating the username, changing the password, and deleting an account.

This approach keeps the screen files focused on displaying the interface, validating user input, and handling navigation. It also makes the code more organized and reusable because different screens can access the same user-related functions through `UserService`.

The basic structure of the implementation is:

**User Interface → UserService → DummyJSON API / Firebase Authentication**

### Benefits of Firebase Implementation

The integration of Firebase improves the Flutter application by providing an actual authentication system in addition to the DummyJSON API used in the previous implementation. Unlike DummyJSON accounts, Firebase allows users to create and manage their own accounts within the application.

Firebase Authentication also provides several account-management features used in this laboratory, including user registration, email and password authentication, username updates, password changes, account deletion, and sign-out functionality. These features make the authentication process more realistic and demonstrate how user accounts can be managed in a Flutter application.

Another benefit is that Firebase authentication is handled separately from the application's UI through the `UserService`. This makes it possible for the application to support both DummyJSON and Firebase without placing all authentication logic inside the Sign In, Sign Up, and Profile screens.

Overall, this laboratory activity demonstrated how an existing Flutter application can be enhanced from using predefined API users to supporting actual user registration and account management through Firebase. It also demonstrated the importance of separating the user interface, service layer, and authentication provider to maintain a cleaner and more manageable application structure.
