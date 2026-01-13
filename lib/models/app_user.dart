class AppUser {
  final String uid;
  final String? email;
  final String? displayName;

  AppUser({required this.uid, this.email, this.displayName});

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
  };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
    uid: map['uid'] as String,
    email: map['email'] as String?,
    displayName: map['displayName'] as String?,
  );
}
