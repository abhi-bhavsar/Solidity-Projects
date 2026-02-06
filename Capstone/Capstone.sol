

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract EtherBay {

    address public owner ; 

    uint public listingfee=1 ether; 

    uint public PlatformProfit ;

    enum state{listed , sold} 

    struct item{
        uint  id ; 
        address payable seller ; 
        address  buyer ;
        string  name ;
        uint  price ; 
        state  status ; 
    }

    mapping(uint=>item) public items ; 
    uint public itemcount ; 
    mapping(address=>uint) public PendingWithdrawals  ; 

    // events
    event  listed(address indexed seller , uint indexed product_id ,uint price) ;
    event sold(address indexed buyer , uint indexed product_id, uint price) ;
    event withdrawal(address indexed seller, uint amount) ;  

    // custom errors 
    error NotOwner() ;
    error NotEnoughEth() ; 
    error ItemNotAvailable() ;
    error ZeroBalance() ; 

    modifier onlyonwer() {
        if(msg.sender!=owner){revert NotOwner() ;}
        _;
    }

    constructor() {
       owner = msg.sender ; 
    }

    function ListItem(string calldata _name ,uint _price) external payable  {
        if(msg.value<listingfee) {revert  NotEnoughEth() ;}

        if(_price==0) {revert("Price must be >0");}

        PlatformProfit += msg.value ;
        itemcount++ ;
        uint newId = itemcount ;

        items[newId] = item({
            id : newId ,
            seller : payable(msg.sender) ,
            buyer :address(0),  
            name : _name ,
            price :  _price ,
            status : state.listed 
             
        }) ;

        emit listed(msg.sender, newId, _price) ;
        
    }


    function buyItem(uint id) external  payable {
        item storage currentItem = items[id] ; 
        
        // validation 

        if(currentItem.status==state.sold) {revert ItemNotAvailable() ; }
        if(currentItem.price<=msg.value ){revert NotEnoughEth();}
        if(currentItem.seller==msg.sender){revert NotOwner() ;}

        currentItem.buyer = msg.sender ;
        currentItem.status = state.sold ; 

        PendingWithdrawals[currentItem.seller] +=msg.value ; 

        if(msg.value>currentItem.price) {
            uint val = msg.value-currentItem.price ;
            (bool success,) = payable(msg.sender).call{value :val }("") ;
            require(success,"Transfer Failed") ;
        }

        emit sold(msg.sender,currentItem.id,currentItem.price) ;
    }

    function WithdrawEarning() external { 
        uint amount_withdrawn = PendingWithdrawals[msg.sender] ; 
    
        if(amount_withdrawn==0) {revert ZeroBalance() ; }

        // security reset of withdrawals to prevent re-entrancy ;
        PendingWithdrawals[msg.sender] = 0  ;

        (bool success, )  = payable(msg.sender).call{value: PendingWithdrawals[msg.sender]}("") ;
        require(success,"Withdrawal Failed");

        emit withdrawal(msg.sender, PendingWithdrawals[msg.sender]) ;
    }

    function GetPlatformProfit() external onlyonwer{
        uint amt = PlatformProfit ; 
        PlatformProfit = 0  ;
        (bool success, ) = payable(msg.sender).call{value : amt}("")  ;
        require(success,"Transfer Failed") ;
    }

    function UpdateListingFee(uint ListingFee) external onlyonwer{
        listingfee = ListingFee;
    }
}