//SPDX-License-Identifier: MIT

//pragma solidity 0.8.0; //ParserError: Source file requires different compiler version
pragma solidity ^0.8.0;

contract web3RSVP{

    //The needed info to create a new event
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

    // will be used as idToEvent(eventID) = CreateEvent
    mapping(bytes32 => CreateEvent) public idToEvent;

    function createNewEvent(
        uint256 eventTimestamp,
        uint256 deposit,
        uint256 maxCapacity,
        string calldata eventDataCID
    ) external {
        // generate an eventId based on other things passed in to generate a hash
        bytes32 eventId = keccak256(
            abi.encodePacked(
                msg.sender,
                address(this),
                eventTimestamp,
                deposit,
                maxCapacity
            )
        );

    // stores the RSVPs in memory, to be used in last section
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

    //Create new RSVP using eventId input
    function createNewRSVP(bytes32 eventId) external payable{

        // Calls the mapping for CreateEvent struct, names it and inputs eventID as the link
        CreateEvent storage myEvent = idToEvent[eventId];

        //sender must send requiret eth for deposit
        require(msg.value == myEvent.deposit, "not enough eth in wallet");

        //The event should not have happened already
        require(block.timestamp <= myEvent.eventTimestamp, "event already happened");
        
        // make sure event is under max capacity
        require(myEvent.confirmedRSVPs.length <= myEvent.maxCapacity, "event full");

        // require that msg.sender isn't already in myEvent.confirmedRSVPs
        for (uint256 index = 0; index < myEvent.confirmedRSVPs.length; index++) {
            require(msg.sender != myEvent.confirmedRSVPs[index], "already signed up");
        }

        //everything checks out - add a new address as RSVP
        myEvent.confirmedRSVPs.push(payable(msg.sender));

    }

    //Check in Attendees
    function confirmAttendee(bytes32 eventId, address attendee) public {


        //look up the event from the mapping using the eventID provided
        CreateEvent storage myEvent = idToEvent[eventId];


        //only owner of event should be able to call the function
        require(msg.sender == myEvent.eventOwner); // NO REPLY

        //To check if attendee signed up beforehand
        address rsvpConfirm;

        //check if the attendee signed up beforehand
        for (uint256 index = 0; index < myEvent.confirmedRSVPs.length; index++) {
            if (myEvent.confirmedRSVPs[index] == attendee){
                rsvpConfirm = myEvent.confirmedRSVPs[index];
            } 
        }
        
        //Check so they are in the list. Reduntant? - if we don't need the response 
        require(rsvpConfirm == attendee, "NO RSVP TO CONFIRM");
        

        //To check if already confirmed 
        //address rsvpClaimed; // OLD SOLUTION

        //check if the attendee is already confirmed
        for (uint256 index = 0; index < myEvent.claimedRSVPs.length; index++) {
            require(myEvent.claimedRSVPs[index] != attendee,"ALREADY CHECKED IN");
            //if (myEvent.claimedRSVPs[index] == attendee) { // OLD solution
            //    rsvpClaimed = myEvent.claimedRSVPs[index];   
            }


           // require(attendee == myEvent.claimedRSVPs[index]);    

        //require(attendee !=rsvpClaimed, "ALREADY CHECKED IN"); // OLD solution

        //Check so owner haven't already claimed deposits
        require(myEvent.paidOut == false,"ALREADY PAID OUT");

        //move the attendee to claimedRSVPs
        myEvent.claimedRSVPs.push(attendee);

        //pay out deposit to attendee
        (bool sent,) = attendee.call{value: myEvent.deposit}(""); // why "(bool sent,)"

        //if it failed to send deposit, remove from claimedRSVPs
        if(!sent){
            myEvent.claimedRSVPs.pop(); // pop removes the last addition 
        }

        require(sent, "FALIED TO SEND");
    }

    //confirm the all of the confirmedRSVPs
    function confirmAll(bytes32 eventId) external{

        //look up the event from the mapping using the eventID provided
        //CreateEvent storage myEvent = idToEvent[eventId]; //OLD own solution
        CreateEvent memory myEvent = idToEvent[eventId]; //memory for only temp use here

        //Check who can call
        require(msg.sender == myEvent.eventOwner, "NOT ALLOWED");

        //Confirm all
        for (uint256 index = 0; index < myEvent.confirmedRSVPs.length; index++) {
            confirmAttendee(eventId, myEvent.confirmedRSVPs[index]);
        }
    }

    function withdrawalFunds(bytes32 eventId) external{

        //look up the event from the mapping using the eventID provided
        CreateEvent storage myEvent = idToEvent[eventId]; //storage for chancing the state

        //Check who can call
        require(msg.sender == myEvent.eventOwner, "NOT ALLOWED");

        //Check required time after event

        //Compare confirmedRSVPs and claimedRSVPs
        // add unclaimed

        //Send to eventOwser
        (bool sent,) = myEvent.eventOwner.call{value unclaimed}("");

        //set paidOut to true
        myEvent.paidOut = true;

    }

}