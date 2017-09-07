//Campaign Contract

pragma solidity ^0.4.6;

contract Campaign{
    //Campaign Owner
    address public owner;

    //Block number is used to track
    uint public deadline;

    //In units of Wei
    uint public goal;

    //Amount Raised
    uint public fundsRaised;

    //Funders
    struct FunderStruct{
    address funder;
    uint amount;
    }

    //check if refund has been send already
    bool refundsSent;

    //Events
    event LogContribution(address sender,uint amount);
    event LogRefund(address funder,uint amount);
    event LogWithdrawal(address beneficiary,uint amount);

    FunderStruct[] public funderStructs;

    //constructor
    function Campgain(uint campaignDuration,uint campaginGoal){
        owner=msg.sender;
        deadline=block.number+campaignDuration;
        goal=campaginGoal;

    }

    /*Check whether campaign was successful
   */
    function isSuccess() public constant returns (bool){
        return (fundsRaised>=goal);
    }

    function hasFailed() public constant returns (bool){
        return ((fundsRaised < goal)&&(deadline<block.number));
    }


    /*
    Function for people to contribute to the campagin
    Returns boolean
    */
    function contribute() public payable returns(bool success){
        if(msg.value==0) revert();
        //checking for deadline
        if(block.number>deadline) revert();
        //stop accepting after success or fail
        if(isSuccess()||hasFailed()) revert();
        if((fundsRaised+msg.value)<fundsRaised) revert();
        fundsRaised+=msg.value;
        FunderStruct memory newFunder;
        newFunder.funder=msg.sender;
        newFunder.amount=msg.value;
        funderStructs.push(newFunder);
        LogContribution(msg.sender,msg.value);
        success=true;
    }

    /*
    Function for owner to withdraw funds
    Returns boolean
    */
    function withdrawFunds() public returns(bool success) {
        if(msg.sender!=owner) revert();
        //check campaign deadline
        if(!isSuccess()) revert();
        uint _amount=this.balance;
        if((owner.balance+_amount)<owner.balance) revert();
        owner.transfer(_amount);
        LogWithdrawal(owner,this.balance);
        success=true;
    }


    /*
    Function to return funds back to contributors if Campaign fails
    Returns boolean
    */
    function sendRefunds() public returns(bool success){
        if(msg.sender!=owner) revert();
        if(!hasFailed()) revert();
        if(refundsSent) revert();
        uint funderCount=funderStructs.length;
        for(uint i=0;i<funderCount;i++){
            if(funderStructs[i].funder.balance+funderStructs[i].amount<funderStructs[i].funder.balance) revert();
            funderStructs[i].funder.transfer(funderStructs[i].amount);
            LogRefund(funderStructs[i].funder,funderStructs[i].amount);
        }
        refundsSent=true;
        return true;
    }

}
