enum ActivityType { event, regular, project, webinar }
enum RegStatus { pending, accepted, rejected, attended, cancelled }
enum UserRole { volunteer, organizer }
enum ActStatus { open, full, closed, finished }

class AppUser {
  String id, name, email, password, city, bio, phone;
  UserRole role;
  List<String> interests;
  String? orgId;
  DateTime joinedAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.role = UserRole.volunteer,
    this.city = '',
    this.bio = '',
    this.phone = '',
    List<String>? interests,
    this.orgId,
    DateTime? joinedAt,
  })  : interests = interests ?? [],
        joinedAt = joinedAt ?? DateTime.now();

  bool get isOrganizer => role == UserRole.organizer;
  String get firstName => name.trim().isEmpty ? '' : name.trim().split(' ').first;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'city': city,
        'bio': bio,
        'phone': phone,
        'role': role.name,
        'interests': interests,
        'orgId': orgId,
        'joinedAt': joinedAt.toIso8601String(),
      };

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'],
        name: j['name'],
        email: j['email'],
        password: j['password'],
        city: j['city'] ?? '',
        bio: j['bio'] ?? '',
        phone: j['phone'] ?? '',
        role: UserRole.values.byName(j['role'] ?? 'volunteer'),
        interests: List<String>.from(j['interests'] ?? []),
        orgId: j['orgId'],
        joinedAt: DateTime.tryParse(j['joinedAt'] ?? ''),
      );
}

class Organization {
  final String id, name, tagline, about, city, category, email, type;
  final bool verified;
  final double rating;
  final int followersBase;
  final String? ownerId;

  const Organization({
    required this.id,
    required this.name,
    required this.tagline,
    required this.about,
    required this.city,
    required this.category,
    this.email = '',
    this.type = 'Komunitas',
    this.verified = false,
    this.rating = 4.5,
    this.followersBase = 0,
    this.ownerId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tagline': tagline,
        'about': about,
        'city': city,
        'category': category,
        'email': email,
        'type': type,
        'verified': verified,
        'rating': rating,
        'followersBase': followersBase,
        'ownerId': ownerId,
      };

  factory Organization.fromJson(Map<String, dynamic> j) => Organization(
        id: j['id'],
        name: j['name'],
        tagline: j['tagline'] ?? '',
        about: j['about'] ?? '',
        city: j['city'] ?? '',
        category: j['category'] ?? 'Sosial',
        email: j['email'] ?? '',
        type: j['type'] ?? 'Komunitas',
        verified: j['verified'] ?? false,
        rating: (j['rating'] ?? 4.5).toDouble(),
        followersBase: j['followersBase'] ?? 0,
        ownerId: j['ownerId'],
      );
}

class Activity {
  final String id, title, orgId, category, city, address, time, description;
  final ActivityType type;
  final bool isOnline;
  final DateTime start, end, deadline, createdAt;
  final int quota, baseJoined, hours;
  final List<String> requirements, benefits, skills, agenda;
  final String? createdBy;

  const Activity({
    required this.id,
    required this.title,
    required this.orgId,
    required this.category,
    required this.type,
    required this.city,
    required this.address,
    required this.isOnline,
    required this.start,
    required this.end,
    required this.deadline,
    required this.time,
    required this.quota,
    required this.baseJoined,
    required this.hours,
    required this.description,
    required this.requirements,
    required this.benefits,
    required this.skills,
    required this.agenda,
    required this.createdAt,
    this.createdBy,
  });

  String get locationLabel => isOnline ? 'Online' : (city.isEmpty ? address : city);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'orgId': orgId,
        'category': category,
        'type': type.name,
        'city': city,
        'address': address,
        'isOnline': isOnline,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'deadline': deadline.toIso8601String(),
        'time': time,
        'quota': quota,
        'baseJoined': baseJoined,
        'hours': hours,
        'description': description,
        'requirements': requirements,
        'benefits': benefits,
        'skills': skills,
        'agenda': agenda,
        'createdAt': createdAt.toIso8601String(),
        'createdBy': createdBy,
      };

  factory Activity.fromJson(Map<String, dynamic> j) => Activity(
        id: j['id'],
        title: j['title'],
        orgId: j['orgId'],
        category: j['category'],
        type: ActivityType.values.byName(j['type']),
        city: j['city'] ?? '',
        address: j['address'] ?? '',
        isOnline: j['isOnline'] ?? false,
        start: DateTime.parse(j['start']),
        end: DateTime.parse(j['end']),
        deadline: DateTime.parse(j['deadline']),
        time: j['time'] ?? '',
        quota: j['quota'] ?? 10,
        baseJoined: j['baseJoined'] ?? 0,
        hours: j['hours'] ?? 2,
        description: j['description'] ?? '',
        requirements: List<String>.from(j['requirements'] ?? []),
        benefits: List<String>.from(j['benefits'] ?? []),
        skills: List<String>.from(j['skills'] ?? []),
        agenda: List<String>.from(j['agenda'] ?? []),
        createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
        createdBy: j['createdBy'],
      );
}

class Registration {
  final String id, activityId, userId, userName;
  RegStatus status;
  String motivation;
  DateTime createdAt;
  int? rating;
  String? review;

  Registration({
    required this.id,
    required this.activityId,
    required this.userId,
    required this.userName,
    this.status = RegStatus.pending,
    this.motivation = '',
    DateTime? createdAt,
    this.rating,
    this.review,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'activityId': activityId,
        'userId': userId,
        'userName': userName,
        'status': status.name,
        'motivation': motivation,
        'createdAt': createdAt.toIso8601String(),
        'rating': rating,
        'review': review,
      };

  factory Registration.fromJson(Map<String, dynamic> j) => Registration(
        id: j['id'],
        activityId: j['activityId'],
        userId: j['userId'],
        userName: j['userName'] ?? '',
        status: RegStatus.values.byName(j['status']),
        motivation: j['motivation'] ?? '',
        createdAt: DateTime.tryParse(j['createdAt'] ?? ''),
        rating: j['rating'],
        review: j['review'],
      );
}

class Notif {
  final String id, userId, title, body, kind;
  final DateTime createdAt;
  bool read;

  Notif({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.kind = 'info',
    DateTime? createdAt,
    this.read = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
        'kind': kind,
        'createdAt': createdAt.toIso8601String(),
        'read': read,
      };

  factory Notif.fromJson(Map<String, dynamic> j) => Notif(
        id: j['id'],
        userId: j['userId'],
        title: j['title'],
        body: j['body'],
        kind: j['kind'] ?? 'info',
        createdAt: DateTime.tryParse(j['createdAt'] ?? ''),
        read: j['read'] ?? false,
      );
}

class Article {
  final String id, title, excerpt, category, author;
  final int minutes;
  final List<String> paragraphs;
  const Article({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.category,
    required this.author,
    required this.minutes,
    required this.paragraphs,
  });
}

class Testimonial {
  final String name, role, text;
  const Testimonial(this.name, this.role, this.text);
}
