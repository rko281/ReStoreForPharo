Extension { #name : #SSWReStoreFunctionTest }

{ #category : #'*SSW ReStore Tests-Pharo' }
SSWReStoreFunctionTest >> testPlatformSpecificFunction [

	"Date>>month is a Pharo-specific method (it exists but has a different meaning and definition in Dolphin) which answers the Month object of the receiver.
	This is mapped to a platform-specific function in all supported SQL dialects"

	| expectedResults results |

	((1 to: 12) collect: [ :index | SimpleProductOrder new quantity: (12 - index); date: (Date newDay: 10 monthIndex: index year: 2020); yourself]) storeAllIn: reStore.

	expectedResults := (1 to: 12) collect: [ :index | {12 - index. Month month: index}].
	results := (SimpleProductOrder storedInstancesIn: reStore) collect: [ :each | each quantity || each date month].
	self assert: (results asSortedCollection: [ :a :b | a first < b first ]) asArray equals: (expectedResults asSortedCollection: [ :a :b | a first < b first ]) asArray
]
