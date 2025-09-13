int getResponsiveCrossAxisCount(double screenWidth) {
  if (screenWidth > 1200) {
    return 4;
  } else if (screenWidth > 900) {
    return 3;
  } else if (screenWidth > 600) {
    return 2;
  } else {
    return 1;
  }
}
