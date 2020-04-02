"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #OwnerTest,
	#superclass : #Object,
	#instVars : [
		'name',
		'number',
		'single1',
		'single2',
		'single3',
		'ownedSet',
		'ownedArray',
		'ownedOrdered',
		'ownedSorted',
		'ownedList',
		'setOfDates',
		'arrayOfNames',
		'orderedBools',
		'sortedNumbers',
		'descNumbers',
		'listOfTimes',
		'dictOfSizes',
		'set',
		'array',
		'ordered',
		'sorted',
		'list',
		'aspectDictionary',
		'keyedBaseDictionary',
		'keyedGeneralDictionary',
		'refreshCount',
		'dependentOwnedOrdered',
		'dependentOrdered'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
OwnerTest class >> reStoreDefinition [

	^super reStoreDefinition
		define: #name as: (String maxSize: 64);
		define: #number as: Integer;
		define: #single1 as: Test;
		define: #single2 as: Test dependent;
		define: #single3 as: Test dependent;	
		define: #ownedSet as: 
			(Set of: OwnedTest dependent owner: #owner);
		define: #ownedArray as:
			((Array new: 4) of: OwnedTest owner: #owner);
		define: #ownedOrdered as: 
			(OrderedCollection of: OwnedTest dependent owner: #owner);
		define: #ownedSorted as:
			(SortedCollection of: OwnedTest owner: #owner);
		define: #ownedList as: 
			((SSWReStoreTest listModelOn: OrderedCollection new) of: OwnedTest dependent owner: #owner) ;

		define: #setOfDates as: (Set of: Date);
		define: #arrayOfNames as: ((Array new: 2) of: (String maxSize: 32));
		define: #orderedBools as: (OrderedCollection of: Boolean);
		define: #sortedNumbers as: (SortedCollection of: Integer);
		define: #descNumbers as: (((SortedCollection sortBlock: [ :x :y | x > y] "sortDescendingOn: #yourself")) of: Integer);
		define: #listOfTimes as: ((SSWReStoreTest listModelOn: OrderedCollection new) of: Time);
		define: #dictOfSizes as: (Dictionary of: String -> Integer);

		define: #set as: (Set of: Test dependent);
		define: #array as: ((Array new: 4) of: Test dependent);
		define: #ordered as: (OrderedCollection of: Test dependent);
		define: #sorted as: ((SortedCollection new" sortAscendingOn: #name") of: Test dependent);
		define: #list as: ((SSWReStoreTest listModelOn: OrderedCollection new) of: Test dependent);
		define: #aspectDictionary as: (Dictionary of: #name -> Test dependent);
		define: #keyedBaseDictionary as: (Dictionary of: String -> Test dependent);
		define: #keyedGeneralDictionary as: (Dictionary of: Test dependent -> Test dependent);
		yourself
]

{ #category : #'instance creation' }
OwnerTest class >> template [

	^self new
		ownedArray: Array new;
		ownedSet: Set new;
		ownedOrdered: OrderedCollection new;
		ownedSorted: OrderedCollection new;
		ownedList: SSWReStoreTest listModelClass new;

		setOfDates: Set new;
		arrayOfNames: Array new;
		orderedBools: OrderedCollection new;
		sortedNumbers: SortedCollection  new;
		descNumbers: SortedCollection  new;
		listOfTimes: SSWReStoreTest listModelClass new;
		dictOfSizes: Dictionary new;

		set: Set new;
		array: Array new;
		ordered: OrderedCollection new;
		sorted: SortedCollection new;
		list: SSWReStoreTest listModelClass new;
		aspectDictionary: Dictionary new;
		keyedBaseDictionary: Dictionary new;
		keyedGeneralDictionary: Dictionary new;
		yourself
]

{ #category : #accessing }
OwnerTest >> <= another [

	^(self single1 name <= another single1 name) |
		((self single1 name = another single1 name) & (self single2 name <= another single2 name))
]

{ #category : #accessing }
OwnerTest >> array [
	"Private - Answer the value of the receiver's ''array'' instance variable."

	^array
]

{ #category : #accessing }
OwnerTest >> array: anObject [
	"Private - Set the value of the receiver's ''array'' instance variable to the argument, anObject."

	array := anObject
]

{ #category : #accessing }
OwnerTest >> arrayOfNames [
	"Private - Answer the value of the receiver's ''arrayOfNames'' instance variable."

	^arrayOfNames
]

{ #category : #accessing }
OwnerTest >> arrayOfNames: anObject [
	"Private - Set the value of the receiver's ''arrayOfNames'' instance variable to the argument, anObject."

	arrayOfNames := anObject
]

{ #category : #accessing }
OwnerTest >> aspectDictionary [
	"Private - Answer the value of the receiver's ''aspectDictionary'' instance variable."

	^aspectDictionary
]

{ #category : #accessing }
OwnerTest >> aspectDictionary: anObject [
	"Private - Set the value of the receiver's ''aspectDictionary'' instance variable to the argument, anObject."

	aspectDictionary := anObject
]

{ #category : #accessing }
OwnerTest >> dependentOrdered [
	^dependentOrdered
]

{ #category : #accessing }
OwnerTest >> dependentOrdered: anObject [
	dependentOrdered := anObject
]

{ #category : #accessing }
OwnerTest >> dependentOwnedOrdered [
	^dependentOwnedOrdered
]

{ #category : #accessing }
OwnerTest >> dependentOwnedOrdered: anObject [
	dependentOwnedOrdered := anObject
]

{ #category : #accessing }
OwnerTest >> descNumbers [
	"Private - Answer the value of the receiver's ''descNumbers'' instance variable."

	^descNumbers
]

{ #category : #accessing }
OwnerTest >> descNumbers: anObject [
	"Private - Set the value of the receiver's ''descNumbers'' instance variable to the argument, anObject."

	descNumbers := anObject
]

{ #category : #accessing }
OwnerTest >> dictOfSizes [
	"Private - Answer the value of the receiver's ''dictOfSizes'' instance variable."

	^dictOfSizes
]

{ #category : #accessing }
OwnerTest >> dictOfSizes: anObject [
	"Private - Set the value of the receiver's ''dictOfSizes'' instance variable to the argument, anObject."

	dictOfSizes := anObject
]

{ #category : #accessing }
OwnerTest >> keyedBaseDictionary [
	"Private - Answer the value of the receiver's ''keyedBaseDictionary'' instance variable."

	^keyedBaseDictionary
]

{ #category : #accessing }
OwnerTest >> keyedBaseDictionary: anObject [
	"Private - Set the value of the receiver's ''keyedBaseDictionary'' instance variable to the argument, anObject."

	keyedBaseDictionary := anObject
]

{ #category : #accessing }
OwnerTest >> keyedGeneralDictionary [
	"Private - Answer the value of the receiver's ''keyedGeneralDictionary'' instance variable."

	^keyedGeneralDictionary
]

{ #category : #accessing }
OwnerTest >> keyedGeneralDictionary: anObject [
	"Private - Set the value of the receiver's ''keyedGeneralDictionary'' instance variable to the argument, anObject."

	keyedGeneralDictionary := anObject
]

{ #category : #accessing }
OwnerTest >> list [
	"Private - Answer the value of the receiver's ''list'' instance variable."

	^list
]

{ #category : #accessing }
OwnerTest >> list: anObject [
	"Private - Set the value of the receiver's ''list'' instance variable to the argument, anObject."

	list := anObject
]

{ #category : #accessing }
OwnerTest >> listOfTimes [
	"Private - Answer the value of the receiver's ''listOfTimes'' instance variable."

	^listOfTimes
]

{ #category : #accessing }
OwnerTest >> listOfTimes: anObject [
	"Private - Set the value of the receiver's ''listOfTimes'' instance variable to the argument, anObject."

	listOfTimes := anObject
]

{ #category : #accessing }
OwnerTest >> mergeUpdate: aSymbol from: anObject [

	^(aSymbol = #name and: [anObject name = 'blockMerge'])
		ifTrue: [false]
		ifFalse: [super mergeUpdate: aSymbol from: anObject]
]

{ #category : #accessing }
OwnerTest >> name [
	^name
]

{ #category : #accessing }
OwnerTest >> name: anObject [
	name := anObject
]

{ #category : #accessing }
OwnerTest >> number [
	^number
]

{ #category : #accessing }
OwnerTest >> number: anObject [
	number := anObject
]

{ #category : #'event handling' }
OwnerTest >> onRefresh [

	self refreshCount: (self refreshCount + 1)
]

{ #category : #accessing }
OwnerTest >> ordered [
	"Private - Answer the value of the receiver's ''ordered'' instance variable."

	^ordered
]

{ #category : #accessing }
OwnerTest >> ordered: anObject [
	"Private - Set the value of the receiver's ''ordered'' instance variable to the argument, anObject."

	ordered := anObject
]

{ #category : #accessing }
OwnerTest >> orderedBools [
	"Private - Answer the value of the receiver's ''orderedBools'' instance variable."

	^orderedBools
]

{ #category : #accessing }
OwnerTest >> orderedBools: anObject [
	"Private - Set the value of the receiver's ''orderedBools'' instance variable to the argument, anObject."

	orderedBools := anObject
]

{ #category : #accessing }
OwnerTest >> ownedArray [
	"Private - Answer the value of the receiver's ''ownedArray'' instance variable."

	^ownedArray
]

{ #category : #accessing }
OwnerTest >> ownedArray: anObject [
	"Private - Set the value of the receiver's ''ownedArray'' instance variable to the argument, anObject."

	ownedArray := anObject
]

{ #category : #accessing }
OwnerTest >> ownedList [
	"Private - Answer the value of the receiver's ''ownedList'' instance variable."

	^ownedList
]

{ #category : #accessing }
OwnerTest >> ownedList: anObject [
	"Private - Set the value of the receiver's ''ownedList'' instance variable to the argument, anObject."

	ownedList := anObject
]

{ #category : #accessing }
OwnerTest >> ownedOrdered [
	"Private - Answer the value of the receiver's ''ownedOrdered'' instance variable."

	^ownedOrdered
]

{ #category : #accessing }
OwnerTest >> ownedOrdered: anObject [
	"Private - Set the value of the receiver's ''ownedOrdered'' instance variable to the argument, anObject."

	ownedOrdered := anObject
]

{ #category : #accessing }
OwnerTest >> ownedSet [
	"Private - Answer the value of the receiver's ''ownedSet'' instance variable."

	^ownedSet
]

{ #category : #accessing }
OwnerTest >> ownedSet: anObject [
	"Private - Set the value of the receiver's ''ownedSet'' instance variable to the argument, anObject."

	ownedSet := anObject
]

{ #category : #accessing }
OwnerTest >> ownedSorted [
	"Private - Answer the value of the receiver's ''ownedSorted'' instance variable."

	^ownedSorted
]

{ #category : #accessing }
OwnerTest >> ownedSorted: anObject [
	"Private - Set the value of the receiver's ''ownedSorted'' instance variable to the argument, anObject."

	ownedSorted := anObject
]

{ #category : #accessing }
OwnerTest >> refreshCount [
	^refreshCount ifNil: [0]
]

{ #category : #accessing }
OwnerTest >> refreshCount: anObject [
	refreshCount := anObject
]

{ #category : #accessing }
OwnerTest >> set [
	"Private - Answer the value of the receiver's ''set'' instance variable."

	^set
]

{ #category : #accessing }
OwnerTest >> set: anObject [
	"Private - Set the value of the receiver's ''set'' instance variable to the argument, anObject."

	set := anObject
]

{ #category : #accessing }
OwnerTest >> setOfDates [
	"Private - Answer the value of the receiver's ''setOfDates'' instance variable."

	^setOfDates
]

{ #category : #accessing }
OwnerTest >> setOfDates: anObject [
	"Private - Set the value of the receiver's ''setOfDates'' instance variable to the argument, anObject."

	setOfDates := anObject
]

{ #category : #accessing }
OwnerTest >> single1 [
	"Private - Answer the value of the receiver's ''single1'' instance variable."

	^single1
]

{ #category : #accessing }
OwnerTest >> single1: anObject [
	"Private - Set the value of the receiver's ''single1'' instance variable to the argument, anObject."

	single1 := anObject
]

{ #category : #accessing }
OwnerTest >> single2 [
	"Private - Answer the value of the receiver's ''single2'' instance variable."

	^single2
]

{ #category : #accessing }
OwnerTest >> single2: anObject [
	"Private - Set the value of the receiver's ''single2'' instance variable to the argument, anObject."

	single2 := anObject
]

{ #category : #accessing }
OwnerTest >> single3 [
	"Private - Answer the value of the receiver's ''single3'' instance variable."

	^single3
]

{ #category : #accessing }
OwnerTest >> single3: anObject [
	"Private - Set the value of the receiver's ''single3'' instance variable to the argument, anObject."

	single3 := anObject
]

{ #category : #accessing }
OwnerTest >> sorted [
	"Private - Answer the value of the receiver's ''sorted'' instance variable."

	^sorted
]

{ #category : #accessing }
OwnerTest >> sorted: anObject [
	"Private - Set the value of the receiver's ''sorted'' instance variable to the argument, anObject."

	sorted := anObject
]

{ #category : #accessing }
OwnerTest >> sortedNumbers [
	"Private - Answer the value of the receiver's ''sortedNumbers'' instance variable."

	^sortedNumbers
]

{ #category : #accessing }
OwnerTest >> sortedNumbers: anObject [
	"Private - Set the value of the receiver's ''sortedNumbers'' instance variable to the argument, anObject."

	sortedNumbers := anObject
]
