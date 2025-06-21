// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract LostObjectPredictor {
    struct LostObject {
        string objectName;
        string lastKnownLocation;
        uint256 timestamp;
        address owner;
        bool isFound;
        string[] predictedLocations;
    }
    
    struct LocationPattern {
        string location;
        uint256 frequency;
        uint256 lastSeen;
    }
    
    mapping(address => LostObject[]) public userLostObjects;
    mapping(address => mapping(string => LocationPattern[])) public userLocationPatterns;
    mapping(address => uint256) public userObjectCount;
    
    event ObjectReported(address indexed user, string objectName, string location, uint256 timestamp);
    event ObjectFound(address indexed user, uint256 objectIndex, string foundLocation);
    event PredictionUpdated(address indexed user, uint256 objectIndex, string[] predictions);
    
    function reportLostObject(
        string memory _objectName,
        string memory _lastKnownLocation,
        string[] memory _predictedLocations
    ) public {
        LostObject memory newObject = LostObject({
            objectName: _objectName,
            lastKnownLocation: _lastKnownLocation,
            timestamp: block.timestamp,
            owner: msg.sender,
            isFound: false,
            predictedLocations: _predictedLocations
        });
        
        userLostObjects[msg.sender].push(newObject);
        userObjectCount[msg.sender]++;
        
        // Update location patterns for this object type
        _updateLocationPattern(msg.sender, _objectName, _lastKnownLocation);
        
        emit ObjectReported(msg.sender, _objectName, _lastKnownLocation, block.timestamp);
    }
    
    function markObjectAsFound(uint256 _objectIndex, string memory _foundLocation) public {
        require(_objectIndex < userLostObjects[msg.sender].length, "Invalid object index");
        require(!userLostObjects[msg.sender][_objectIndex].isFound, "Object already marked as found");
        
        userLostObjects[msg.sender][_objectIndex].isFound = true;
        
        // Update location patterns with found location
        string memory objectName = userLostObjects[msg.sender][_objectIndex].objectName;
        _updateLocationPattern(msg.sender, objectName, _foundLocation);
        
        emit ObjectFound(msg.sender, _objectIndex, _foundLocation);
    }
    
    function updatePredictions(uint256 _objectIndex, string[] memory _newPredictions) public {
        require(_objectIndex < userLostObjects[msg.sender].length, "Invalid object index");
        require(!userLostObjects[msg.sender][_objectIndex].isFound, "Cannot update predictions for found object");
        
        userLostObjects[msg.sender][_objectIndex].predictedLocations = _newPredictions;
        
        emit PredictionUpdated(msg.sender, _objectIndex, _newPredictions);
    }
    
    function getUserLostObjects(address _user) public view returns (LostObject[] memory) {
        return userLostObjects[_user];
    }
    
    function _updateLocationPattern(address _user, string memory _objectType, string memory _location) internal {
        LocationPattern[] storage patterns = userLocationPatterns[_user][_objectType];
        
        // Check if location already exists in patterns
        for (uint256 i = 0; i < patterns.length; i++) {
            if (keccak256(abi.encodePacked(patterns[i].location)) == keccak256(abi.encodePacked(_location))) {
                patterns[i].frequency++;
                patterns[i].lastSeen = block.timestamp;
                return;
            }
        }
        
        // Add new location pattern
        patterns.push(LocationPattern({
            location: _location,
            frequency: 1,
            lastSeen: block.timestamp
        }));
    }
}v
