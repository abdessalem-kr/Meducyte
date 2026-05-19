import 'package:equatable/equatable.dart';

class Book extends Equatable {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String description;
  final String category; //e.g.,Cardiology,Surgery
  final int year; //e.g.,1,2,3...
  final double rating;
  final bool isPremium;
  final String? pdfUrl;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.description,
    required this.category,
    required this.year,
    this.rating = 0.0,
    this.isPremium = false,
    this.pdfUrl,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    author,
    coverUrl,
    description,
    category,
    year,
    rating,
    isPremium,
    pdfUrl,
  ];
}

final List<Book> mockBooks = [
  const Book(
    id: '1',
    title: 'Harrison\'s Principles of Internal Medicine',
    author: 'J.Larry Jameson',
    coverUrl: 'assets/images/books/harrisons.png',
    description:
        'Harrison\'s Principles of Internal Medicine is the world\'s most trusted clinical medicine text—and a superb resource for learning the art and science of clinical reasoning.Recognized by healthcare professionals worldwide as the leading authority on applied pathophysiology and clinical medicine.',
    category: 'Internal Medicine',
    year: 4,
    rating: 4.9,
    isPremium: true,
    pdfUrl:
        'https://www.google.com/search?q=Harrisons+Principles+of+Internal+Medicine+pdf',
  ),
  const Book(
    id: '2',
    title: 'Gray\'s Anatomy',
    author: 'Henry Gray',
    coverUrl: 'assets/images/books/grays.png',
    description:
        'The undisputed classic of human anatomy.This comprehensive guide provides detailed anatomical descriptions and surgical applications,featuring the legendary illustrations that have made it a cornerstone of medical education for generations.',
    category: 'Anatomy',
    year: 1,
    rating: 4.8,
    pdfUrl: 'https://www.google.com/search?q=Grays+Anatomy+pdf',
  ),
  const Book(
    id: '3',
    title: 'Robbins Basic Pathology',
    author: 'Vinay Kumar',
    coverUrl: 'assets/images/books/robbins.png',
    description:
        'Robbins Basic Pathology provides a readable,well-illustrated and concise overview of the principles of human pathology that\'s ideal for today\'s busy students.This thoroughly revised edition continues with a strong emphasis on pathogenesis and the clinical features of disease.',
    category: 'Pathology',
    year: 3,
    rating: 4.7,
    pdfUrl: 'https://www.google.com/search?q=Robbins+Basic+Pathology+pdf',
  ),
  const Book(
    id: '4',
    title: 'Guyton and Hall Textbook of Medical Physiology',
    author: 'John E.Hall',
    coverUrl: 'assets/images/books/guyton.png',
    description:
        'The world\'s favorite physiology textbook.Recognized for its unique focus on the most relevant concepts for students in medicine and healthcare,this text uses a"homeostatic"approach to describe how the various systems of the body work together to maintain life.',
    category: 'Physiology',
    year: 2,
    rating: 4.8,
    pdfUrl:
        'https://www.google.com/search?q=Guyton+and+Hall+Textbook+of+Medical+Physiology+pdf',
  ),
];
