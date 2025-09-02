import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/logger.dart';

class DataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return UserModel.fromJson(doc.data() ?? {});
  }

  Future<void> updateUser(String uid, UserModel user) async {
    await _db.collection('users').doc(uid).set(user.toJson());
  }
  
  // Initialize a new user document in Firestore when they sign up
  Future<void> initializeUserData(String uid, String email, String displayName) async {
    // Check if user already exists
    final userDoc = await _db.collection('users').doc(uid).get();
    
    if (!userDoc.exists) {
      // Create initial user document
      await _db.collection('users').doc(uid).set({
        'email': email,
        'displayName': displayName,
        'weaknesses': [],
        'pdfs': [],
        'studiedLectures': [],
        'quizHistory': [],
        'lastActive': FieldValue.serverTimestamp()
      });
    }
  }

  Future<void> updateWeaknesses(String uid, List<String> newWeaknesses) async {
    try {
      // First check if the document exists
      final docRef = _db.collection('users').doc(uid);
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
        // Document exists, use update
        await docRef.update({'weaknesses': newWeaknesses});
      } else {
        // Document doesn't exist, create it
        await docRef.set({
          'email': '',
          'displayName': 'User',
          'weaknesses': newWeaknesses,
          'pdfs': [],
          'studiedLectures': [],
          'quizHistory': [],
          'lastActive': FieldValue.serverTimestamp()
        });
        Logger.info('Created new user document for $uid during weaknesses update');
      }
    } catch (e) {
      Logger.error('Error updating weaknesses: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getYears() async {
    // Fetch years from Firestore
    try {
      final coursesSnapshot = await _db.collection('courses').get();
      
      // If no courses exist yet, initialize the database structure
      if (coursesSnapshot.docs.isEmpty) {
        await initializeDatabaseSchema();
        // Fetch again after initialization
        return await getYears();
      }
      
      // Extract unique years from courses collection
      Set<String> uniqueYears = {};
      for (var doc in coursesSnapshot.docs) {
        uniqueYears.add(doc.data()['year']);
      }
      
      // Return as formatted list
      return uniqueYears.map((year) => {'id': year, 'name': year}).toList();
    } catch (e) {
      Logger.error('Error fetching years: $e');
      // Fallback to hardcoded values if error occurs
      return [
        {'id': 'Year 1', 'name': 'Year 1'},
        {'id': 'Year 2', 'name': 'Year 2'},
        {'id': 'Year 3', 'name': 'Year 3'},
      ];
    }
  }
  
  // Initialize the database schema with courses structure
  Future<void> initializeDatabaseSchema() async {
    // Check if initialization already happened
    final initDoc = await _db.collection('meta').doc('initialization').get();
    if (initDoc.exists) {
      return; // Already initialized
    }
    
    // Create batch for atomic writes
    final batch = _db.batch();
    
    // Year 1 Courses
    final year1Sem1 = _db.collection('courses').doc();
    batch.set(year1Sem1, {
      'year': 'Year 1',
      'semester': 'Semester 1',
      'courseName': 'Computer Science',
      'subjects': [
        {
          'id': 'cs101',
          'name': 'Introduction to Programming',
          'professor': 'Dr. Brown'
        },
        {
          'id': 'math101',
          'name': 'Discrete Mathematics',
          'professor': 'Dr. Smith'
        },
        {
          'id': 'sda101',
          'name': 'Data Structures and Algorithms',
          'professor': 'Dr. Johnson'
        }
      ]
    });
    
    final year1Sem2 = _db.collection('courses').doc();
    batch.set(year1Sem2, {
      'year': 'Year 1',
      'semester': 'Semester 2',
      'courseName': 'Computer Science',
      'subjects': [
        {
          'id': 'cs102',
          'name': 'Object Oriented Programming',
          'professor': 'Dr. Williams'
        },
        {
          'id': 'db101',
          'name': 'Database Fundamentals',
          'professor': 'Dr. Davis'
        },
        {
          'id': 'os101',
          'name': 'Operating Systems',
          'professor': 'Dr. Miller'
        }
      ]
    });
    
    // Year 2 Courses
    final year2Sem1 = _db.collection('courses').doc();
    batch.set(year2Sem1, {
      'year': 'Year 2',
      'semester': 'Semester 1',
      'courseName': 'Computer Science',
      'subjects': [
        {
          'id': 'ai201',
          'name': 'Introduction to AI',
          'professor': 'Dr. Wilson'
        },
        {
          'id': 'net201',
          'name': 'Computer Networks',
          'professor': 'Dr. Taylor'
        }
      ]
    });
    
    // Sample Lectures for Data Structures (SDA101)
    final lecture1 = _db.collection('lectures').doc();
    batch.set(lecture1, {
      'title': 'Introduction to Data Structures',
      'content': '''
# Introduction to Data Structures

Data structures are specialized formats for organizing, processing, retrieving and storing data. They are designed to make data access more efficient. The choice of the right data structure can significantly improve the performance of an algorithm.

## Types of Data Structures

### 1. Arrays
An array is a collection of items stored at contiguous memory locations. The idea is to store multiple items of the same type together.

### 2. Linked Lists
A linked list is a linear data structure where each element is a separate object, called a node. Each node contains data and a reference to the next node in the sequence.

### 3. Stacks
A stack is a linear data structure that follows the Last In First Out (LIFO) principle. The last item to be inserted into a stack is the first one to be deleted from it.

### 4. Queues
A queue is a linear data structure that follows the First In First Out (FIFO) principle. The first item to be inserted into a queue is the first one to be deleted from it.

### 5. Trees
A tree is a hierarchical data structure that consists of nodes connected by edges. Each node contains a value and may have zero or more child nodes.

### 6. Graphs
A graph is a non-linear data structure consisting of nodes (vertices) and edges. The edges connect any two vertices in the graph.

### 7. Hash Tables
A hash table is a data structure that implements an associative array abstract data type, a structure that can map keys to values.

## Importance of Data Structures

Choosing the right data structure is essential for:
- Efficient data organization
- Faster data processing
- Memory optimization
- Simplified problem solving

In the upcoming lectures, we will explore each of these data structures in detail, discussing their implementations, operations, and applications.
''',
      'courseId': year1Sem1.id,
      'subjectId': 'sda101',
      'author': 'Dr. Johnson',
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    final lecture2 = _db.collection('lectures').doc();
    batch.set(lecture2, {
      'title': 'Arrays and Linked Lists',
      'content': '''
# Arrays and Linked Lists

In this lecture, we'll compare two fundamental data structures: Arrays and Linked Lists.

## Arrays

Arrays store elements in contiguous memory locations, resulting in easily calculable addresses for the elements stored.

### Characteristics of Arrays:
1. **Random Access**: Elements can be accessed directly using their index
2. **Fixed Size**: Size is specified at declaration time (in many languages)
3. **Homogeneous Elements**: All elements are of the same type
4. **Memory Allocation**: Memory is allocated at compile time (static arrays)

### Operations on Arrays:
- **Access**: O(1) - Constant time
- **Search**: O(n) - Linear time for unsorted arrays, O(log n) for sorted arrays with binary search
- **Insertion**: O(n) - Worst case requires shifting elements
- **Deletion**: O(n) - Worst case requires shifting elements

## Linked Lists

Linked lists consist of nodes where each node contains data and a reference to the next node.

### Characteristics of Linked Lists:
1. **Sequential Access**: Elements must be accessed sequentially
2. **Dynamic Size**: Can grow or shrink during execution
3. **Memory Allocation**: Memory is allocated at runtime
4. **Memory Usage**: Requires extra space for pointers

### Types of Linked Lists:
- **Singly Linked List**: Each node has a data field and a reference to the next node
- **Doubly Linked List**: Each node has a data field and references to both the next and previous nodes
- **Circular Linked List**: Last node points to the first node, forming a circle

### Operations on Linked Lists:
- **Access**: O(n) - Linear time
- **Search**: O(n) - Linear time
- **Insertion**: O(1) - Constant time if position is known
- **Deletion**: O(1) - Constant time if position is known

## Comparison: Arrays vs Linked Lists

| Operation | Arrays | Linked Lists |
|-----------|--------|-------------|
| Access    | O(1)   | O(n)        |
| Insert    | O(n)   | O(1)        |
| Delete    | O(n)   | O(1)        |
| Memory    | Fixed  | Dynamic     |

### When to Use Arrays:
- When you need constant-time access to elements
- When the size is known and fixed
- When memory efficiency is important

### When to Use Linked Lists:
- When frequent insertions and deletions are required
- When the size is unknown or changes frequently
- When you don't need random access to elements

In the next lecture, we'll explore more complex data structures built using arrays and linked lists.
''',
      'courseId': year1Sem1.id,
      'subjectId': 'sda101',
      'author': 'Dr. Johnson',
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // Sample Lecture for Database Fundamentals (DB101)
    final lecture3 = _db.collection('lectures').doc();
    batch.set(lecture3, {
      'title': 'Introduction to Database Systems',
      'content': '''
# Introduction to Database Systems

A database is an organized collection of structured information, or data, typically stored electronically in a computer system. A database is usually controlled by a database management system (DBMS).

## What is a Database Management System (DBMS)?

A DBMS is a software system that allows users to define, create, maintain, and control access to a database. It provides a systematic way to create, retrieve, update, and manage data.

## Types of Database Models

### 1. Relational Database
The most common type of database, where data is organized into tables (relations) with rows and columns. Each row represents a unique record, and each column represents a field in the record.

### 2. NoSQL Database
Designed for specific data models with flexible schemas for building modern applications. Types include:
- Document databases
- Key-value stores
- Wide-column stores
- Graph databases

### 3. Object-Oriented Database
Data is represented in the form of objects, as used in object-oriented programming.

### 4. Hierarchical Database
Data is organized in a tree-like structure, with each record having one parent record and many children.

## Components of a Database System

### 1. Data Definition Language (DDL)
Used to define and modify the database structure. Commands include CREATE, ALTER, DROP.

### 2. Data Manipulation Language (DML)
Used to manipulate data within the database. Commands include SELECT, INSERT, UPDATE, DELETE.

### 3. Data Control Language (DCL)
Used to control access to data within the database. Commands include GRANT, REVOKE.

## Key Database Concepts

### 1. Schema
The structure that represents the logical view of the entire database.

### 2. Table
A collection of related data entries consisting of columns and rows.

### 3. Record/Row
A single entry in a table, representing a set of related data values.

### 4. Field/Column
A single piece of data within a record.

### 5. Key
A field or combination of fields that uniquely identifies a record.

### 6. Index
A data structure that improves the speed of data retrieval operations.

## Benefits of Database Systems

- Data independence
- Reduced data redundancy
- Data consistency
- Improved data sharing
- Enhanced data security
- Improved decision making

In our next lecture, we will explore relational database design principles and normalization.
''',
      'courseId': year1Sem2.id,
      'subjectId': 'db101',
      'author': 'Dr. Davis',
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // Mark as initialized
    batch.set(_db.collection('meta').doc('initialization'), {
      'initialized': true,
      'timestamp': FieldValue.serverTimestamp()
    });
    
    // Commit all changes as a single transaction
    await batch.commit();
  }
  
  // Get semesters for a specific year
  Future<List<Map<String, dynamic>>> getSemestersByYear(String year) async {
    try {
      final snapshot = await _db.collection('courses')
          .where('year', isEqualTo: year)
          .get();
      
      Set<String> semesters = {};
      for (var doc in snapshot.docs) {
        semesters.add(doc.data()['semester']);
      }
      
      return semesters.map((sem) => {'id': sem, 'name': sem}).toList();
    } catch (e) {
      Logger.error('Error fetching semesters: $e');
      return [];
    }
  }
  
  // Get courses for a specific year and semester
  Future<List<Map<String, dynamic>>> getCoursesByYearAndSemester(String year, String semester) async {
    try {
      final snapshot = await _db.collection('courses')
          .where('year', isEqualTo: year)
          .where('semester', isEqualTo: semester)
          .get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        'name': doc.data()['courseName']
      }).toList();
    } catch (e) {
      Logger.error('Error fetching courses: $e');
      return [];
    }
  }
  
  // Get subjects for a specific course
  Future<List<Map<String, dynamic>>> getSubjectsByCourse(String courseId) async {
    try {
      final doc = await _db.collection('courses').doc(courseId).get();
      if (!doc.exists) {
        return [];
      }
      return List<Map<String, dynamic>>.from(doc.data()?['subjects'] ?? []);
    } catch (e) {
      Logger.error('Error fetching subjects: $e');
      return [];
    }
  }

  // Get all lectures for a subject
  Future<List<Map<String, dynamic>>> getLecturesBySubject(String courseId, String subjectId) async {
    try {
      final snapshot = await _db.collection('lectures')
          .where('courseId', isEqualTo: courseId)
          .where('subjectId', isEqualTo: subjectId)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to the data
        return data;
      }).toList();
    } catch (e) {
      Logger.error('Error fetching lectures: $e');
      return [];
    }
  }
  
  // Get a specific lecture by ID
  Future<Map<String, dynamic>?> getLecture(String lectureId) async {
    try {
      final doc = await _db.collection('lectures').doc(lectureId).get();
      if (!doc.exists) {
        return null;
      }
      
      final data = doc.data()!;
      data['id'] = doc.id; // Add document ID to the data
      return data;
    } catch (e) {
      Logger.error('Error fetching lecture: $e');
      return null;
    }
  }
  
  // Add a PDF reference to user document
  Future<String> addPdf(String uid, String name, String courseId, String subjectId, String storagePath) async {
    // Create document in pdfs collection
    final pdfRef = await _db.collection('pdfs').add({
      'name': name,
      'userId': uid,
      'courseId': courseId,
      'subjectId': subjectId,
      'uploadDate': FieldValue.serverTimestamp(),
      'url': storagePath, // This should be a Firebase Storage path (gs://...)
    });
    
    // Add reference to user document
    final pdfData = {
      'id': pdfRef.id,
      'name': name,
      'courseId': courseId,
      'subjectId': subjectId,
      'uploadDate': FieldValue.serverTimestamp(),
      'url': storagePath
    };
    
    await _db.collection('users').doc(uid).update({
      'pdfs': FieldValue.arrayUnion([pdfData])
    });
    
    return pdfRef.id;
  }
  
  // Mark a lecture as studied by the user
  Future<void> markLectureAsStudied(String uid, String lectureId, String title, String courseId, String subjectId) async {
    final studyData = {
      'id': lectureId,
      'title': title,
      'courseId': courseId,
      'subjectId': subjectId,
      'studiedAt': FieldValue.serverTimestamp(),
    };
    
    await _db.collection('users').doc(uid).update({
      'studiedLectures': FieldValue.arrayUnion([studyData])
    });
  }

  // Save a new quiz and its result
  Future<String> saveQuiz(
    String uid,
    String courseId, 
    String subjectName, 
    List<Map<String, dynamic>> questions, 
    int score
  ) async {
    // Create quiz document
    final quizRef = await _db.collection('quizzes').add({
      'userId': uid,
      'courseId': courseId,
      'subjectName': subjectName,
      'createdAt': FieldValue.serverTimestamp(),
      'questions': questions
    });
    
    // Add to user's quiz history
    final quizResult = {
      'quizId': quizRef.id,
      'courseId': courseId,
      'subject': subjectName,
      'date': FieldValue.serverTimestamp(),
      'score': score
    };
    
    await updateQuizHistory(uid, quizResult);
    
    return quizRef.id;
  }

  Future<void> updateQuizHistory(String uid, Map<String, dynamic> quizResult) async {
    try {
      // First check if the document exists
      final docRef = _db.collection('users').doc(uid);
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
        // Document exists, use update
        await docRef.update({
          'quizHistory': FieldValue.arrayUnion([quizResult])
        });
      } else {
        // Document doesn't exist, create it
        await docRef.set({
          'email': '',
          'displayName': 'User',
          'weaknesses': [],
          'pdfs': [],
          'studiedLectures': [],
          'quizHistory': [quizResult],
          'lastActive': FieldValue.serverTimestamp()
        });
        Logger.info('Created new user document for $uid during quiz submission');
      }
    } catch (e) {
      Logger.error('Error updating quiz history: $e');
      rethrow;
    }
  }
}
