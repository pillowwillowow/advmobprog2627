## Laboratory Discussion

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
