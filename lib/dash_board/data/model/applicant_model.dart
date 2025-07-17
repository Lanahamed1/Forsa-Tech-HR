class ApplicantModel {
  final PersonalDetails personalDetails;
  final String summary;
  final List<Skill> skills;
  final List<Education> education;
  final List<Project> projects;
  final List<Experience> experiences;
  final List<TrainingCourse> trainingsCourses;

  ApplicantModel({
    required this.personalDetails,
    required this.summary,
    required this.skills,
    required this.education,
    required this.projects,
    required this.experiences,
    required this.trainingsCourses,
  });

  factory ApplicantModel.fromJson(Map<String, dynamic> json) => ApplicantModel(
        personalDetails: PersonalDetails.fromJson(json['personal_details']),
        summary: json['summary'],
        skills: List<Skill>.from(json['skills'].map((x) => Skill.fromJson(x))),
        education: List<Education>.from(
            json['education'].map((x) => Education.fromJson(x))),
        projects: List<Project>.from(
            json['projects'].map((x) => Project.fromJson(x))),
        experiences: List<Experience>.from(
            json['experiences'].map((x) => Experience.fromJson(x))),
        trainingsCourses: List<TrainingCourse>.from(
            json['trainings_courses'].map((x) => TrainingCourse.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'personal_details': personalDetails.toJson(),
        'summary': summary,
        'skills': skills.map((x) => x.toJson()).toList(),
        'education': education.map((x) => x.toJson()).toList(),
        'projects': projects.map((x) => x.toJson()).toList(),
        'experiences': experiences.map((x) => x.toJson()).toList(),
        'trainings_courses': trainingsCourses.map((x) => x.toJson()).toList(),
      };
}

class PersonalDetails {
  final String username;
  final String email;
  final String? phone;
  final String? location;
  final String? githubLink;
  final String? linkedinLink;

  PersonalDetails({
    required this.username,
    required this.email,
    this.phone,
    this.location,
    this.githubLink,
    this.linkedinLink,
  });

  factory PersonalDetails.fromJson(Map<String, dynamic> json) =>
      PersonalDetails(
        username: json['username'],
        email: json['email'],
        phone: json['phone'],
        location: json['location'],
        githubLink: json['github_link'],
        linkedinLink: json['linkedin_link'],
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'email': email,
        'phone': phone,
        'location': location,
        'github_link': githubLink,
        'linkedin_link': linkedinLink,
      };
}

class Skill {
  final String skill;
  final String? level;

  Skill({
    required this.skill,
    this.level,
  });

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        skill: json['skill'],
        level: json['level'],
      );

  Map<String, dynamic> toJson() => {
        'skill': skill,
        'level': level,
      };
}

class Education {
  final String degree;
  final String institution;
  final String startDate;
  final String endDate;
  final String? description; 

  Education({
    required this.degree,
    required this.institution,
    required this.startDate,
    required this.endDate,
    this.description,
  });

  factory Education.fromJson(Map<String, dynamic> json) => Education(
        degree: json['degree'],
        institution: json['institution'],
        startDate: json['start_date'],
        endDate: json['end_date'],
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        'degree': degree,
        'institution': institution,
        'start_date': startDate,
        'end_date': endDate,
        'description': description,
      };
}

class Project {
  final String title;
  final String description;
  final String? githubLink;

  Project({
    required this.title,
    required this.description,
    this.githubLink,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        title: json['title'],
        description: json['description'],
        githubLink: json['github_link'],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'github_link': githubLink,
      };
}

class Experience {
  final String jobTitle;
  final String company;
  final String? startDate;
  final String? endDate;
  final String? description;

  Experience({
    required this.jobTitle,
    required this.company,
    this.startDate,
    this.endDate,
    this.description,
  });

  factory Experience.fromJson(Map<String, dynamic> json) => Experience(
        jobTitle: json['job_title'],
        company: json['company'],
        startDate: json['start_date'],
        endDate: json['end_date'],
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        'job_title': jobTitle,
        'company': company,
        'start_date': startDate,
        'end_date': endDate,
        'description': description,
      };
}

class TrainingCourse {
  final String title;
  final String institution;
  final String? startDate;
  final String? endDate;
  final String? description;

  TrainingCourse({
    required this.title,
    required this.institution,
    this.startDate,
    this.endDate,
    this.description,
  });

  factory TrainingCourse.fromJson(Map<String, dynamic> json) => TrainingCourse(
        title: json['title'],
        institution: json['institution'],
        startDate: json['start_date'],
        endDate: json['end_date'],
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'institution': institution,
        'start_date': startDate,
        'end_date': endDate,
        'description': description,
      };
}
