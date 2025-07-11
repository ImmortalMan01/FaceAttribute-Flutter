class Account {
  final String username;
  final String password;
  final bool isAdmin;

  const Account({required this.username, required this.password, required this.isAdmin});

  factory Account.fromMap(Map<String, dynamic> data) {
    return Account(
      username: data['username'],
      password: data['password'],
      isAdmin: data['isAdmin'] == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'username': username,
      'password': password,
      'isAdmin': isAdmin ? 1 : 0,
    };
  }
}
