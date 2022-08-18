"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SimplePerson,
	#superclass : #Object,
	#instVars : [
		'firstName',
		'surname',
		'emailAddress',
		'time',
		'friend',
		'age',
		'test',
		'orders',
		'address',
		'isDeceased'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SimplePerson class >> new [

	^super new
		time: DateAndTime now;
		orders: OrderedCollection new;
		isDeceased: false;
		yourself
]

{ #category : #public }
SimplePerson class >> reStoreDefinition [

	^super reStoreDefinition
		define: #surname as: (String maxSize: 100);
		define: #firstName as: (String maxSize: 50);
		define: #emailAddress as: (String maxSize: 100);
		define: #time as: DateAndTime;
		define: #friend as: SimplePerson;
		define: #age as: Integer;
		define: #test as: Test;
		define: #address as: SimpleAddress dependent;
		define: #isDeceased as: Boolean;
		yourself
]

{ #category : #comparing }
SimplePerson >> <= aPerson [

	^self surname < aPerson surname | ((self surname = aPerson surname) & (self firstName <= aPerson firstName))
]

{ #category : #comparing }
SimplePerson >> <== aPerson [

	"Same implementation as <= but using Blocks"

	^self surname < aPerson surname or: [self surname = aPerson surname and: [self firstName <= aPerson firstName]]
]

{ #category : #comparing }
SimplePerson >> <==> aPerson [

	"Inverse implementation of <=="

	^aPerson surname > self surname or: [aPerson surname = self surname and: [aPerson firstName >= self firstName]]
]

{ #category : #comparing }
SimplePerson >> <=> aPerson [

	"Inverse implementation of <="

	^aPerson surname > self surname | ((aPerson surname = self surname) & (aPerson firstName >= self firstName))
]

{ #category : #accessing }
SimplePerson >> _instVarAt: anInteger [

	anInteger = 1 ifTrue: 
		[firstName = '<ERROR>' ifTrue: [firstName := '<done>'. self error: firstName].
		firstName = '<ERROR ON COMMIT 1>' ifTrue: [firstName := '<ERROR>'].
		firstName = '<ERROR ON COMMIT>' ifTrue: [firstName := '<ERROR ON COMMIT 1>']].

	^super _instVarAt: anInteger
]

{ #category : #accessing }
SimplePerson >> address [
	^address
]

{ #category : #accessing }
SimplePerson >> address: anObject [
	address := anObject
]

{ #category : #accessing }
SimplePerson >> age [
	^age
]

{ #category : #accessing }
SimplePerson >> age: anObject [
	age := anObject
]

{ #category : #accessing }
SimplePerson >> emailAddress [
	"Private - Answer the value of the receiver's ''emailAddress'' instance variable."

	^emailAddress
]

{ #category : #accessing }
SimplePerson >> emailAddress: anObject [
	"Private - Set the value of the receiver's ''emailAddress'' instance variable to the argument, anObject."

	emailAddress := anObject
]

{ #category : #accessing }
SimplePerson >> firstName [
	"Private - Answer the value of the receiver's ''firstName'' instance variable."

	^firstName
]

{ #category : #accessing }
SimplePerson >> firstName: anObject [
	"Private - Set the value of the receiver's ''firstName'' instance variable to the argument, anObject."

	firstName := anObject
]

{ #category : #accessing }
SimplePerson >> friend [
	^friend
]

{ #category : #accessing }
SimplePerson >> friend: anObject [
	friend := anObject
]

{ #category : #comparing }
SimplePerson >> friendCompare: aSimplePerson [

	^self friend standardCompare: aSimplePerson friend
]

{ #category : #comparing }
SimplePerson >> friendCompareWithBlocks: aSimplePerson [

	^self friend standardCompareWithBlocks: aSimplePerson friend
]

{ #category : #testing }
SimplePerson >> friendIsNilAndJohn [

	^self friend isNil and: [self firstName = 'John']
]

{ #category : #testing }
SimplePerson >> friendIsNilOrJohn [

	^self friend isNil or: [self firstName = 'John']
]

{ #category : #testing }
SimplePerson >> friendNotNilAndJim [

	^self friend notNil and: [self firstName = 'Jim']
]

{ #category : #testing }
SimplePerson >> friendNotNilOrJim [

	^self friend notNil or: [self firstName = 'Jim']
]

{ #category : #accessing }
SimplePerson >> fullName [

	^self firstName, ' ', self surname
]

{ #category : #accessing }
SimplePerson >> fullNameDirect [

	^firstName, ' ', surname
]

{ #category : #accessing }
SimplePerson >> fullNameWithEvaluationLocation [

	^self 
		imageDo: [self fullName, ' (IMAGE)']
		databaseDo: [self fullName, ' (DATABASE)']
]

{ #category : #testing }
SimplePerson >> hasFriend [

	^self friend notNil
]

{ #category : #testing }
SimplePerson >> hasNoFriend [

	^self friend isNil
]

{ #category : #testing }
SimplePerson >> hasNoTest [

	^self test isNil
]

{ #category : #testing }
SimplePerson >> hasTest [

	^self test notNil
]

{ #category : #testing }
SimplePerson >> hasTestOrFriendHasTestBlock [

	^self test notNil or: [self friend test notNil]
]

{ #category : #testing }
SimplePerson >> isBrown20 [

	^self surname = 'Brown' and: [self age = 20]
]

{ #category : #testing }
SimplePerson >> isDavidAndTestIsNil [

	^self firstName = 'David' and: [self test isNil]
]

{ #category : #testing }
SimplePerson >> isDavidOrTestIsNil [

	^self firstName = 'David' or: [self test isNil]
]

{ #category : #accessing }
SimplePerson >> isDeceased [
	^isDeceased
]

{ #category : #accessing }
SimplePerson >> isDeceased: anObject [
	isDeceased := anObject
]

{ #category : #testing }
SimplePerson >> isJohnAndTestIsNil [

	^self firstName = 'John' and: [self test isNil]
]

{ #category : #accessing }
SimplePerson >> orderCount [

	^self orders size
]

{ #category : #accessing }
SimplePerson >> orders [
	^orders
]

{ #category : #accessing }
SimplePerson >> orders: anObject [
	orders := anObject
]

{ #category : #comparing }
SimplePerson >> standardCompare: aPerson [

	"Works with friendCompare:"

	^self surname < aPerson surname | ((self surname = aPerson surname) & (self firstName <= aPerson firstName))
]

{ #category : #comparing }
SimplePerson >> standardCompareWithBlocks: aPerson [

	"Works with friendCompareWithBlocks:"

	^self surname < aPerson surname or: [self surname = aPerson surname and: [self firstName <= aPerson firstName]]
]

{ #category : #accessing }
SimplePerson >> surname [
	"Private - Answer the value of the receiver's ''surname'' instance variable."

	^surname
]

{ #category : #accessing }
SimplePerson >> surname: anObject [
	"Private - Set the value of the receiver's ''surname'' instance variable to the argument, anObject."

	surname := anObject
]

{ #category : #accessing }
SimplePerson >> test [
	^test
]

{ #category : #accessing }
SimplePerson >> test: anObject [
	test := anObject
]

{ #category : #accessing }
SimplePerson >> time [
	"Private - Answer the value of the receiver's ''time'' instance variable."

	^time
]

{ #category : #accessing }
SimplePerson >> time: anObject [
	"Private - Set the value of the receiver's ''time'' instance variable to the argument, anObject."

	time := anObject
]
