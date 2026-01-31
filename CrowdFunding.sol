// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; 
// crowdfunding in which we fund a project or venture by raising money from large number of people 


// there will contributors and there will be recipent like(child education , homeless housing , women edu )
// manage will make request on behalf of these recipent 
// the voting of individual funders will decide who will recieve the donation


contract Crowdfunding { 

    struct request{

        string description ; 
        address payable recipent ; 
        uint value ;
        bool Completed ; 
        uint noofVoters ;
        mapping(address=>bool ) voters ;
    }

    mapping(uint=>request) public Requests ; 
    uint public NoOfRequest ; 

    mapping(address=>uint) public contributor ; 
    address public Manager ; 
    uint public MinContribution  ; 
    uint public Target  ;
    uint public TotalContributor  ;
    uint public Deadline ;
    uint public RaisedAmount ; 


    constructor(uint _target , uint deadline ){
        Manager = msg.sender ;
        Target = _target ; 
        Deadline = block.timestamp + deadline ;
        MinContribution = 1 ether ;
    }

    modifier OnlyManager() {
        require(msg.sender==Manager, "Yoo are not the manager ") ;
        _; 
    }

    function CreateRequest(string memory _description  , address payable _recipent , uint _value) public OnlyManager {
        request storage NewRequest = Requests[NoOfRequest] ;
        NoOfRequest++ ;
        NewRequest.description = _description  ; 
        NewRequest.recipent = _recipent ; 
        NewRequest.value = _value ;
        NewRequest.noofVoters = 0; 
        NewRequest.Completed = false ;
    }

    function Contribution()public payable   {
        require(block.timestamp<Deadline, "Deadline has Passed ") ;
        require(msg.value>=MinContribution,"Send More Eth");

        if(contributor[msg.sender]==0) {
            TotalContributor++ ;
        }
        contributor[msg.sender] += msg.value ;
        RaisedAmount += msg.value ;
     }

     function GetContractBalance()public view returns(uint) { 
        return address(this).balance ; 
     }

     function GetRefund() public{
        require(block.timestamp>Deadline && RaisedAmount<Target,"You are not eligible for refund")  ;
        require(contributor[msg.sender]>0,"You are not the contributor") ; 
        uint refundAmount = contributor[msg.sender] ;
        delete contributor[msg.sender] ; 
        (bool success, )  =payable(msg.sender).call{value : refundAmount}("")  ;
        require(success,"transfer failed");
     }

     function VoteRequest(uint _requireNO)public  {
        require(contributor[msg.sender]>0,"You are not Contributor");
        require(block.timestamp>Deadline,"Wait Till deadline overs") ;
        request storage thisrequest = Requests[_requireNO] ;
        require(thisrequest.voters[msg.sender]==false,"You have voted"); 
        thisrequest.voters[msg.sender]==true ;
        thisrequest.noofVoters++ ;
      }

      function makePayment(uint request_no) public OnlyManager  {
        require(RaisedAmount>Target,"Target isnt reached yet") ;
     request storage thisRequest = Requests[request_no] ; 
     require(thisRequest.Completed==false , "The request is completed"); 
     require(thisRequest.noofVoters>TotalContributor/2 , "Not enough votes") ;

    (bool success ,) =  payable(thisRequest.recipent).call{value: thisRequest.value}("");
     require(success,"Payment failed");
     thisRequest.Completed = true ;
      }

    // uint public bkl =  block.timestamp ;  
}
