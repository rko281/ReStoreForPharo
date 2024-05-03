Class {
	#name : #FieldNameTest,
	#superclass : #Object,
	#instVars : [
		'id',
		'name',
		'description'
	],
	#classInstVars : [
		'shouldUseAlternativeNames'
	],
	#category : #'SSW ReStore Tests'
}

{ #category : #persistency }
FieldNameTest class >> reStoreDefinition [

	^self shouldUseAlternativeNames
		ifTrue: [self reStoreDefinitionWithAlternativeNames]
		ifFalse: [self reStoreDefinitionStandard]
]

{ #category : #persistency }
FieldNameTest class >> reStoreDefinitionStandard [

	^super reStoreDefinition
		defineAsID: #id;
		define: #name as: (String maxSize: 128);
		define: #description as: (String maxSize: 255);
		yourself
]

{ #category : #persistency }
FieldNameTest class >> reStoreDefinitionWithAlternativeNames [

	^super reStoreDefinition
		defineAsID: (#id withDatabaseName: 'my_id') ;
		define: (#name withDatabaseName: 'my_name') as: (String maxSize: 128);
		define: (#description previouslyNamed: #detailedDescription) as: (String maxSize: 255);
		yourself
]

{ #category : #accessing }
FieldNameTest class >> shouldUseAlternativeNames [

	^shouldUseAlternativeNames ifNil: [false]
]

{ #category : #accessing }
FieldNameTest class >> shouldUseAlternativeNames: aBoolean [

	shouldUseAlternativeNames := aBoolean
]

{ #category : #accessing }
FieldNameTest >> description [
	^description
]

{ #category : #accessing }
FieldNameTest >> description: anObject [
	description := anObject
]

{ #category : #accessing }
FieldNameTest >> id [
	^id
]

{ #category : #accessing }
FieldNameTest >> id: anObject [
	id := anObject
]

{ #category : #accessing }
FieldNameTest >> name [
	^name
]

{ #category : #accessing }
FieldNameTest >> name: anObject [
	name := anObject
]
