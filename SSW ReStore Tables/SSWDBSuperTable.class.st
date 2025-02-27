"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBSuperTable',
	#superclass : 'SSWDBInheritedTable',
	#category : 'SSW ReStore Tables',
	#package : 'SSW ReStore Tables'
}

{ #category : 'evaluating' }
SSWDBSuperTable >> forCreation [

	"Create and return a new SSWDBSuperTable with merged fields
	from all the receiver's instanceClass's persistence subclasses"
	
	| tableForCreation |
	
	tableForCreation := self class forClass: self instanceClass.
	tableForCreation 
		name: self name;
		fullName: self fullName;
		namespace: self namespace.
	
	tableForCreation initializeIn: self reStore.
	self instanceClass reStoreDefinition addDefinitionToTable: tableForCreation.
	
	self instanceClass subclassesInheritingPersistency do:
		[ :cls || table |
		table := cls tableIn: self reStore.
		tableForCreation instanceClass: cls.
		table dataFields do: 
			[ :field | 
			(tableForCreation hasFieldAccessing: field accessor name) ifFalse: 
				[tableForCreation dataFields add: field]].
		table collectionSpecs do:
			[ :spec |
			(tableForCreation hasCollectionAccessing: spec accessor name) ifFalse: 
				[tableForCreation collectionSpecs add: spec]]].

	tableForCreation instanceClass: self instanceClass.
	
	^tableForCreation
]

{ #category : 'defining' }
SSWDBSuperTable >> initializeIn: anSSWReStore [

	"Overriden to setup the classField"

	super initializeIn: anSSWReStore.
	self setDefaultClassField
]

{ #category : 'instance creation' }
SSWDBSuperTable >> refreshProxy: aProxy whereChangedFromRow: aDBRow [

	"Redirect to the relevant concrete class"
	
	| class |
	
	class := self instanceClassFromRow: aDBRow.

	^class = self instanceClass
		ifTrue: [super refreshProxy: aProxy whereChangedFromRow: aDBRow]
		ifFalse: [(self reStore tableForClass: class) refreshProxy: aProxy whereChangedFromRow: aDBRow]
]
