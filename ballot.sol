pragma solidity >0.4.0 <=0.6.0;

contract Voting
{
    struct voter
    {
        bool voted;
        uint weight;
        address delegate;
        uint proposal;
    }

    address public chairperson;
    //uint public votingdeadline


    uint public winningproposal=0;

    struct Proposal
    {
        uint votecount;

    }

    Proposal[4] public proposals;
    uint public noofproposals=4;
    mapping (address=>voter) public voters;

    modifier OnlyChairperson()
    {
        require(chairperson==msg.sender);
        _;
    }

    constructor(/*uint votingperioduint noOfProposals*/) public
    {
        chairperson = msg.sender;
        voters[chairperson].weight=1;
        //noofproposals=noOfProposals;
        voters[chairperson].voted=false;
        voters[chairperson].weight=1;
        //votingdeadline=now+votingperiod
        /*for(uint i=0;i<noOfProposals;i++)
        {
                proposals[i].votecount=0;
        }*/
    }

    function giveRightToVote(address ofvoter) public OnlyChairperson
    {
         require(!voters[ofvoter].voted);
         require(voters[ofvoter].weight==0);
         voters[ofvoter].weight=1;
    }

    function delegateto(address todelegate) public
    {
        require(!voters[msg.sender].voted);
        require(todelegate != msg.sender);
        while(voters[todelegate].delegate!=address(0))
        {
           todelegate=voters[todelegate].delegate;
           require(todelegate!=msg.sender); //loop
        }

        //check whether delegated has already cast his vote,if yes add 1 to the proposal of delegate else increment weight of delegate
        if(!voters[todelegate].voted)
        {
            voters[todelegate].weight+=voters[msg.sender].weight;
        }
        else
        {
            proposals[voters[todelegate].proposal].votecount+=voters[todelegate].weight;

        }
        voters[msg.sender].voted=true;
        voters[msg.sender].delegate=todelegate;
        voters[msg.sender].weight=0;

    }

    function vote(uint pr) public
    {
        require(!voters[msg.sender].voted,"already done");
        voters[msg.sender].voted=true;
        voters[msg.sender].proposal=pr;
        proposals[pr].votecount+=voters[msg.sender].weight;
        voters[msg.sender].weight=0;

    }

    function calculateWinningProposal() public OnlyChairperson /*votingtime*/
    {
        uint winningcount=0;
        for(uint i=0;i<noofproposals;i++)
        {
            if(proposals[i].votecount>winningcount)
            {
                winningcount=proposals[i].votecount;
                winningproposal=i;
            }
        }



    }
}
