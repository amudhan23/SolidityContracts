pragma solidity >0.4.0 <=0.6.0;
pragma experimental ABIEncoderV2;

contract blindauction
{
    uint public revealDeadLine;
    uint public biddingdeadline;
    uint public biddingStartingTime;

    uint public highestbid;
    address public highestbidder;
    bool beneficiaryHasCalled;
    bool toBeneficiaryTransferred;

    address payable beneficiary;

    struct Bid
    {
            bytes32 blindedbid;
            uint deposit;
    }

    mapping(address=>Bid[]) bids;

    constructor(address payable Beneficiary,uint biddingtime,uint revealtime) public
    {
        beneficiary=Beneficiary;
        biddingStartingTime=now;
        biddingdeadline=now+biddingtime;
        revealDeadLine=biddingdeadline+revealtime;
    }

    mapping(address=>uint) pendingbid;

    modifier beforTime(uint _time)
    {
        require(now<=_time);
        _;
    }

    modifier afterTime(uint _time)
    {
        require(now>_time);
        _;
    }

    function getHashedBit(uint a,bool b,string memory c) public pure returns(bytes32)
    {
            bytes32 hashedvalue;
            hashedvalue=keccak256(abi.encodePacked(a,b,c));
            return hashedvalue;

    }

    function BlindBid(bytes32 _blindedbid) payable public beforTime(biddingdeadline)
    {
        require(beneficiary!=msg.sender);
        bids[msg.sender].push(Bid(
            {
            blindedbid: _blindedbid,
            deposit: msg.value
        }
        ));

    }


    function reveal(uint[] memory _values,bool[] memory _bool,string[] memory _secret) public afterTime(biddingdeadline) beforTime(revealDeadLine)
    {
        require(beneficiary!=msg.sender);
        uint length1 = bids[msg.sender].length;
        require(_values.length==length1 && _bool.length==length1 && _bool.length==length1);
        uint refund;


        for (uint i = 0; i < length1; i++)
        {
            Bid storage bid = bids[msg.sender][i];
            (uint value, bool fake, string memory secret) =
                    (_values[i], _bool[i], _secret[i]);
            if (bid.blindedbid!= keccak256(abi.encodePacked(value, fake, secret)))
            {
                continue;
            }
            refund += bid.deposit;
            if (!fake && bid.deposit >= value) {
                if (placebid(msg.sender, value))
                    refund -= value;
            }
            bid.blindedbid = bytes32(0);
        }
        msg.sender.transfer(refund);
    }







    function placebid(address _ad,uint _value) internal returns(bool)
    {
        //uint value = msg.value;
        //require(beneficiary!=msg.sender,"no beneficiary bid");
        if(_value<highestbid)
        {
                return false;
        }
        if(highestbidder!=address(0))
        {
            pendingbid[highestbidder]+=highestbid;
        }
        highestbid=_value;
        highestbidder=_ad;
        return true;
    }

    function returnback() public afterTime(revealDeadLine) returns(bool)
    {
         //bool truetransaction;
         uint amount= pendingbid[msg.sender];
         require(beneficiaryHasCalled,"Beneficiary has not called yet");
         require(beneficiary!=msg.sender);
         /*if(highestbidder==msg.sender)
         {
            amount-=highestbid;
         }*/
         if(amount>0)
         {
            if(!msg.sender.send(amount))
            {
                pendingbid[msg.sender]=amount;
                return false;
            }
            else
            {
                pendingbid[msg.sender]=0;
                return true;
            }
        }
    }

    function toBeneficiary() afterTime(revealDeadLine)  public
    {
        require(beneficiary==msg.sender,"Not Beneficiary");
        beneficiaryHasCalled=true;
        if(beneficiary.send(highestbid))
        {
            pendingbid[highestbidder]-=highestbid;
            toBeneficiaryTransferred=true;
        }
        else
        {
            toBeneficiaryTransferred=false;
        }
    }

    function currentTime() public view  returns(uint)
    {
        return now;
    }
}









                  
