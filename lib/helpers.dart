// General helper functions

// function to return 2 digits month or day
String twoDigit(String temp) {
  if (temp.length == 1) {
    return "0" + temp;
  } else if (temp.length == 4) {
    return temp.substring(temp.length - 2);
  } else {
    return temp;
  }
}

// function to return the audio URL
String generateAudioUrl(DateTime picked) {
  String month = twoDigit(picked.month.toString());
  String day = twoDigit(picked.day.toString());
  String year = twoDigit(picked.year.toString());
  String fullYear = picked.year.toString();

  return 'https://dzxuyknqkmi1e.cloudfront.net/odb/$fullYear/$month/odb-$month-$day-$year.mp3';
}

////  return the image URL
String generateImageUrl(DateTime picked) {
  String month = twoDigit(picked.month.toString());
  String day = twoDigit(picked.day.toString());
  String year = picked.year.toString();
  String fullYear = picked.year.toString();
  return 'https://d626yq9e83zk1.cloudfront.net/files/$fullYear/$month/odb$year$month$day.jpg';
}
