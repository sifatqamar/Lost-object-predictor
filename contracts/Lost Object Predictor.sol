function getTopLocations(address _user, string memory _objectType, uint256 _topN) public view returns (LocationPattern[] memory) {
    LocationPattern[] storage allPatterns = userLocationPatterns[_user][_objectType];
    uint256 n = allPatterns.length < _topN ? allPatterns.length : _topN;

    // Create a memory copy to sort
    LocationPattern[] memory sorted = new LocationPattern[](allPatterns.length);
    for (uint256 i = 0; i < allPatterns.length; i++) {
        sorted[i] = allPatterns[i];
    }

    // Simple selection sort by frequency (can be optimized)
    for (uint256 i = 0; i < n; i++) {
        uint256 maxIndex = i;
        for (uint256 j = i + 1; j < sorted.length; j++) {
            if (sorted[j].frequency > sorted[maxIndex].frequency) {
                maxIndex = j;
            }
        }
        // Swap
        if (i != maxIndex) {
            LocationPattern memory temp = sorted[i];
            sorted[i] = sorted[maxIndex];
            sorted[maxIndex] = temp;
        }
    }

    // Return top N
    LocationPattern[] memory topLocations = new LocationPattern[](n);
    for (uint256 i = 0; i < n; i++) {
        topLocations[i] = sorted[i];
    }

    return topLocations;
}
