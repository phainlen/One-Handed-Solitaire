# Define the suits and ranks
$suits = @('H', 'D', 'C', 'S')
#$suits = @([char]9825,[char]9826,[char]9827,[char]9824)
$ranks = @('2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A')

# Create an array to hold the deck of cards
[System.Collections.ArrayList]$deck = @()

# Create the deck
foreach ($suit in $suits) {
    foreach ($rank in $ranks) {
		
        $deck += "$rank$suit"
    }
}

# Shuffle the deck using Fisher-Yates algorithm
$deckSize = $deck.Count
for ($i = $deckSize - 1; $i -gt 0; $i--) {
    $j = Get-Random -Minimum 0 -Maximum ($i + 1)
    $temp = $deck[$i]
    $deck[$i] = $deck[$j]
    $deck[$j] = $temp
}

<#
           |----------------------------\/
		[DECK] | [Extra] -->  [Playable]  --> [Discard]
		0..51  |  0 .. 51       0 .. 3 
#>

# We need to store the shuffled deck into an array list so we can modify the deck as needed
[System.Collections.ArrayList]$shuffledDeck = $deck
#The four cards that the player is concerned about
$playableHand = [System.Collections.ArrayList]::new()
#$playableHand = @{}
#The cards that were in the player's hand that couldn't be matched
$extraHand = [System.Collections.ArrayList]::new()
#$extraHand = @{}

#break;
$number_of_cards_in_deck=$shuffledDeck.Count

$Continue_processing_extra_cards = $true

#for ($number_of_cards_in_deck;$number_of_cards_in_deck -ge 0;$number_of_deck_left--)
while ($number_of_cards_in_deck -ge 0)
{
	$number_of_cards_in_playable_hand = $playableHand.Count
	
	#Write-Host "# Cards in playable hand: $number_of_cards_in_playable_hand"
	
	# Fill the player's hand with 4 cards if they need it
	# Check to see if there are cards in the extra hand to add to the left side first, then add cards from the deck to the right

	#See if there are card in the extra hand first
	$number_of_cards_in_extra_hand = $extraHand.Count
	#Write-Host "# Cards in extra hand: $number_of_cards_in_extra_hand"
	
	for ($j = $number_of_cards_in_extra_hand;($number_of_cards_in_playable_hand -lt 4 -and $number_of_cards_in_extra_hand -gt 0);$j--)
	{
		#Insert the new card on the left side of the hand from the shuffled deck
		#ie if the number of cards in playable hand is 2 we will insert at 2-1 (1) and then the next time around 1-1 (0)
		$extra_hand_spot = $number_of_cards_in_extra_hand - 1
		$playableHand.Insert(0,$extraHand[$extra_hand_spot]) | out-null
		
		#Be sure to remove that card from the extra hand after inserting into the playable hand
		$extraHand.RemoveAt($number_of_cards_in_extra_hand -1)
		$number_of_cards_in_playable_hand = $playableHand.Count
		$number_of_cards_in_extra_hand = $extraHand.Count
		
	}

	#If the player's hand is still not full then check the deck
	$number_of_cards_in_deck = $shuffledDeck.Count

	for ($k = $number_of_cards_in_deck;($number_of_cards_in_playable_hand -lt 4 -and $number_of_cards_in_deck -gt 0);$k--)
	{
		#Insert the new card on the right side of the hand from the shuffled deck
		#if the playable hand cards = 2, then we want to put the new card in slot 2 and then slot 3
		$deck_spot = $number_of_cards_in_deck - 1
		$playableHand.Add($shuffledDeck[$deck_spot]) | out-null
		$shuffledDeck.RemoveAt($number_of_cards_in_deck -1)
		
		#Write-Host "Removing cards, shuffled deck = $shuffledDeck"
		$number_of_cards_in_playable_hand = $playableHand.Count
		$number_of_cards_in_deck = $shuffledDeck.Count
	}
	
	<#
	    Check to see if there are matches and remove the cards necessary
	#>
	
	write-host "$number_of_cards_in_deck cards in Deck       : $shuffledDeck"
	write-host "$number_of_cards_in_extra_hand Extra Cards: $extraHand"		
	write-host "$number_of_cards_in_playable_hand in Player Hand: $playableHand"
	#pause
	$number_of_cards_in_deck = $shuffledDeck.Count
	$number_of_cards_in_extra_hand = $extraHand.Count
	$number_of_cards_in_playable_hand = $playableHand.Count
	
	if ($number_of_cards_in_playable_hand -gt 2)
	{
		$LastCardNumber = $playableHand[3].Substring(0,1)
		$LastCardSuit   = $playableHand[3].Substring(1,1)
	}
	elseif($number_of_cards_in_playable_hand -eq 2)
	{
		$LastCardNumber = $playableHand[1].Substring(0,1)
		$LastCardSuit   = $playableHand[1].Substring(1,1)		
	}
	else #zero cards left!  You win!
	{
		Write-Host "You Won"
		break
	}
	
	$FirstCardNumber  = $playableHand[0].Substring(0,1)
	$FirstCardSuit    = $playableHand[0].Substring(1,1)

	if ($LastCardNumber -eq $FirstCardNumber)
	{
		#Discard all four playable cards
		#When removing at 0 then everything changes numbers. 1 becomes 0.  if we remove starting with the last card then we can remove them in reverse order.
		if ($number_of_cards_in_playable_hand -gt 2)
		{
			$playableHand.RemoveAt(3)
			$playableHand.RemoveAt(2)
			$playableHand.RemoveAt(1)
			$playableHand.RemoveAt(0)
		}
		else
		{
			$playableHand.RemoveAt(1)
			$playableHand.RemoveAt(0)
		}
		
		$Continue_processing_extra_cards = $true #This is important for processing the final cards when the deck is empty

	}
	elseif (($LastCardSuit -eq $FirstCardSuit) -and ($number_of_cards_in_playable_hand -gt 2))
	{
		#Discard middle two playable cards.
		$playableHand.RemoveAt(1) | out-null
		#When removing at 1 then everything changes numbers. 2 becomes 1.  So we need to remove #1 again.
		$playableHand.RemoveAt(1) | out-null
		$Continue_processing_extra_cards = $true #This is important for processing the final cards when the deck is empty
	}
	else #no matches? add a card from the deck to the playable hand and move the first card from the playable hand to the extra stack
	{
		#we now need to add cards from the deck and shift cards in the players hand to the extra hand
		if ($number_of_cards_in_deck -gt 0)
		{
			#Add the first card in the playable hand to the end of the extra hand
			$extraHand.Add($playableHand[0]) | out-null
			$playableHand.RemoveAt(0) | out-null
			#Add the top card of the deck at the end of the playable hand
			$playableHand.Add($shuffledDeck[$number_of_cards_in_deck -1]) | out-null
			$shuffledDeck.RemoveAt($number_of_cards_in_deck -1) | out-null
		}
	}

	if (($number_of_cards_in_deck -eq 0) -and ($Continue_processing_extra_cards))
	{
		Write-Host "The deck cards are gone.  Checking to see if your hand has more matches."
		$Continue_processing_extra_cards = $false
	}
	elseif (($number_of_cards_in_deck -eq 0) -and (($number_of_cards_in_extra_hand -gt 0) -or ($number_of_cards_in_playable_hand -gt 0)))
	{
		$cards_left = ($number_of_cards_in_extra_hand + $number_of_cards_in_playable_hand)
		Write-Host "You Lost with $cards_left cards left."
		break
	}
	elseif (($number_of_cards_in_deck -eq 0) -and (($number_of_cards_in_extra_hand -eq 0) -or ($number_of_cards_in_playable_hand -eq 0)))
	{
		Write-Host "You Won"
		break

	}
}

<#
The deck cards are gone.  Checking to see if your hand has more matches.
0 cards in Deck       :
0 Extra Cards:
2 in Player Hand: 8D 2D
You cannot call a method on a null-valued expression.
At C:\Users\phain\Downloads\One-Handed-Solitaire.ps1:100 char:2
+     $FourthCardNumber = $playableHand[3].Substring(0,1)
+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: (:) [], RuntimeException
    + FullyQualifiedErrorId : InvokeMethodOnNull

You cannot call a method on a null-valued expression.
At C:\Users\phain\Downloads\One-Handed-Solitaire.ps1:101 char:2
+     $FourthCardSuit   = $playableHand[3].Substring(1,1)
+     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: (:) [], RuntimeException
    + FullyQualifiedErrorId : InvokeMethodOnNull

Exception calling "RemoveAt" with "1" argument(s): "Index was out of range. Must be non-negative and less than the
size of the collection.
Parameter name: index"
#>
