# arellano_advmobprog

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

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