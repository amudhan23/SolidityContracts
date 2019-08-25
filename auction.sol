pragma solidity >=0.4.0 <0.6.0;

contract Auction
{
    address payable beneficiary;

    uint public biddingtime;
    uint public Auctionend;

    uint public HighestBid;
    address public HighestBidder;

    mapping(address => uint) pendingTransactions;

    event highestbid(address,uint);
    event Auctionended();

    bool ended;

    constructor (address payable _beneficiary,uint _biddingtime) public
    {
        beneficiary = _beneficiary;
        Auctionend = now+_biddingtime;
    }

    function bid()  public payable
    {
        require(now <= Auctionend);
        require(msg.value > HighestBid);

        if(HighestBid!=0)
        {
            pendingTransactions[HighestBidder] += HighestBid;
        }

        HighestBid = msg.value;
        HighestBidder = msg.sender;

        emit highestbid(msg.sender,HighestBid);

    }

    function withdraw() public returns(bool)
    {
        uint amount = pendingTransactions[msg.sender];
        if(amount!=0)
        {
            pendingTransactions[msg.sender]=0;

            if(!msg.sender.send(amount))
            {
                pendingTransactions[msg.sender]=amount;
                return false;
            }
        }
        return true;

    }

    function closetheacution() public
    {
        require(now >= Auctionend,"Auction has not ended");
        require(!ended,"closetheacution fn has already been called");

        ended = true;
        emit Auctionended();

        beneficiary.transfer(HighestBid);
    }


}
