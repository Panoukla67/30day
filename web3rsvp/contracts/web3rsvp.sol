struct CreateEvent {
    bytes32 eventId;
    string eventDataCID;
    address eventOwner;
    uint256 eventTimestamp;
    uint256 deposit;
    uint256 maxCapacity;
    address[] confirmedRSVPs;
    address[] claimedRSVPs;
    bool paidOut;
}

mapping(bytes32 => CreateEvent) public idToEvent;

function createNewEvent(
    uint256 eventTimestamp,
    uint256 deposit,
    uint256 maxCapacity,
    string calldata eventDataCID
) external {
    // generate an eventID based on other things passed in to generate a hash
    bytes32 eventId = keccak256(
        abi.encodePacked(
            msg.sender,
            address(this),
            eventTimestamp,
            deposit,
            maxCapacity
        )
    );

function createNewRSVP(bytes32 eventId) external payable{
    // looks up the event in the mapping, based on input 
    CreateEvent storage myEvent, idToEvent[eventID];

    require(msg.value == myEvent.deposit, "not enough eth in wallet");

    require(block.timestamp <= myEvent.eventTimestamp, "event already happened");
    
    // make sure event is under max capacity
    require(myEvent.confirmedRSVPs.length <= myEvent.maxCapacity, "event full");

     // require that msg.sender isn't already in myEvent.confirmedRSVPs
     for (uint256 index = 0; index < myEvent.confirmedRSVPs.length; index++) {
        require(msg.sender != myEvent.confirmedRSVPs[index], "already signed up");
     }

     //add a new address as RSVP
     myEvent.confirmedRSVPs.push(payable(msg.sender));

}   

    address[] memory confirmedRSVPs;
    address[] memory claimedRSVPs;


    // this creates a new CreateEvent struct and adds it to the idToEvent mapping
    idToEvent[eventId] = CreateEvent(
        eventId,
        eventDataCID,
        msg.sender,
        eventTimestamp,
        deposit,
        maxCapacity,
        confirmedRSVPs,
        claimedRSVPs,
        false
    );
}