import 'dart:typed_data';

import 'package:flutter_media_metadata/flutter_media_metadata.dart';

class SongInfo {
  SongInfo({
    this.trackName,
    this.trackArtistNames,
    this.albumName,
    this.albumArtistName,
    this.trackNumber,
    this.albumLength,
    this.year,
    this.genre,
    this.authorName,
    this.writerName,
    this.discNumber,
    this.mimeType,
    this.trackDuration,
    this.bitrate,
    this.albumArt,
    this.filePath,
  });

  final String trackName;
  final List<dynamic> trackArtistNames;
  final String albumName;
  final String albumArtistName;
  final int trackNumber;
  final int albumLength;
  final int year;
  final String genre;
  final String authorName;
  final String writerName;
  final int discNumber;
  final String mimeType;
  final int trackDuration;
  final int bitrate;
  final Uint8List albumArt;
  final String filePath;

  /// ## Access Metadata as a Map
  ///
  ///  You may use [toMap] method to get metadata in form of a `Map<String, dynamic>`.
  ///
  ///     Map<String, dynamic> metadataMap = metadata.toMap();
  ///

  Map<String, dynamic> toMap() {
    return {
      'trackName': this.trackName,
      'trackArtistNames': this.trackArtistNames,
      'albumName': this.albumName,
      'albumArtistName': this.albumArtistName,
      'trackNumber': this.trackNumber,
      'albumLength': this.albumLength,
      'year': this.year,
      'genre': this.genre,
      'authorName': this.authorName,
      'writerName': this.writerName,
      'discNumber': this.discNumber,
      'mimeType': this.mimeType,
      'trackDuration': this.trackDuration,
      'bitrate': this.bitrate,
      'albumArt': this.albumArt,
      'filePath': this.filePath,
    };
  }

  static SongInfo setData(Metadata metaData, Uint8List image, String path) {
    return SongInfo(
      albumArt: image,
      filePath: path,
      albumArtistName: metaData.albumArtistName,
      albumLength: metaData.albumLength,
      albumName: metaData.albumName,
      authorName: metaData.authorName,
      bitrate: metaData.bitrate,
      discNumber: metaData.discNumber,
      genre: metaData.genre,
      mimeType: metaData.mimeType,
      trackArtistNames: metaData.trackArtistNames,
      trackDuration: metaData.trackDuration,
      trackName: metaData.trackName,
      trackNumber: metaData.trackNumber,
      writerName: metaData.writerName,
      year: metaData.year,
    );
  }
}
