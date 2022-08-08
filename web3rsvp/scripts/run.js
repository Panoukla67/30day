const hre = require("hardhat");

const main = async () => {

    //Hardhat is used to deploy the contract
    //const rsvpContractFactory = await hre.ethers.getContractFactory("web3rsvp");
    const rsvpContractFactory = await hre.ethers.getContractFactory("web3RSVP");
    const rsvpContract = await rsvpContractFactory.deploy();
    await rsvpContract.deployed();
    console.log("Contract deployed to:",rsvpContract.address);

    //Addresses for testing
    const [deployer, address1, address2] = await hre.ethers.getSigners();

    //Define event data
    let deposit = hre.ethers.utils.parseEther("1");
    let maxCapacity = 3;
    let timeStamp = 1718926200;
    let eventDataCID = "bafybeibhwfzx6oo5rymsxmkdxpmkfwyvbjrrwcl7cekmbzlupmp5ypkyfi";

    //create event
    let txn = await rsvpContract.createNewEvent(
        timeStamp,
        deposit,
        maxCapacity,
        eventDataCID
      );
      let wait = await txn.wait();
      console.log("NEW EVENT CREATED:", wait.events[0].event, wait.events[0].args);
      
      let eventId = wait.events[0].args.eventId;
      console.log("EVENT ID:", eventId);


    //copy
    txn = await rsvpContract.createNewRSVP(eventId, { value: deposit });
    wait = await txn.wait();
    console.log("NEW RSVP:", wait.events[0].event, wait.events[0].args);

    txn = await rsvpContract
    .connect(address1)
    .createNewRSVP(eventId, { value: deposit });
    wait = await txn.wait();
    console.log("NEW RSVP:", wait.events[0].event, wait.events[0].args);

    txn = await rsvpContract
    .connect(address2)
    .createNewRSVP(eventId, { value: deposit });
    wait = await txn.wait();
    console.log("NEW RSVP:", wait.events[0].event, wait.events[0].args);



    //confirm all attendees
    txn = await rsvpContract.confirmAll(eventId);
    wait = await txn.wait();
    wait.events.forEach((event) =>
    console.log("CONFIRMED:", event.args.attendee) //changed
    );

    //pass time
    await hre.network.provider.send("evm_increaseTime", [15778800000000]);

    txn = await rsvpContract.withdrawalFunds(eventId);
    wait = await txn.wait();
    console.log("WITHDRAWN:", wait.events[0].event, wait.events[0].args);


};








const runMain = async () =>{
    try{
        await main();
        process.exit(0);
    } catch (error){
        console.log(error);
        process.exit(1);
    }
};

runMain();