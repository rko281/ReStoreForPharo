"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBClassDefinition',
	#superclass : 'Object',
	#instVars : [
		'definedClass',
		'instVarDefinitions',
		'tableName',
		'idInstVar',
		'namespace'
	],
	#category : 'SSW ReStore Tables',
	#package : 'SSW ReStore Tables'
}

{ #category : 'instance creation' }
SSWDBClassDefinition class >> forClass: aClass [

	^super new
		definedClass: aClass;
		instVarDefinitions: OrderedCollection new;
		yourself
]

{ #category : 'defining' }
SSWDBClassDefinition >> addDefinitionToTable: aDBTable [

	self instVarDefinitions do: [ :assoc | aDBTable define: assoc key as: assoc value].

	self tableName isNil ifFalse: [aDBTable name: self tableName].
	self idInstVar isNil ifFalse: [aDBTable defineAsID: self idInstVar].
	self namespace isNil ifFalse: [aDBTable namespace: self namespace]
]

{ #category : 'converting' }
SSWDBClassDefinition >> asTableIn: aReStore [

	| table |

	table := self definedClass reStoreTableClass forClass: self definedClass in: aReStore.

	self addDefinitionToTable: table.
		
	^table isDefined
		ifTrue: [table]
		ifFalse: [nil]
]

{ #category : 'defining' }
SSWDBClassDefinition >> define: aSymbol as: aClass [

	"Define the inst var named aSymbol as holding instances of aClass.	 
	aClass could be an actual Class, a ClassWithInfo or a CollectionSpec (defining a Collection).
	Example usage of each type:
		define: #notes as: String;
		define: #name as: (String maxSize: 200);	
		define: #children as: (Collection of: Person owner: #parent)"

	self instVarDefinitions add: (aSymbol -> aClass)
]

{ #category : 'accessing' }
SSWDBClassDefinition >> defineAsID: aSymbol [

	"OPTIONAL:

	Define the receiver's unique ID as the inst var named aSymbol.
	Use of this method enables persistent objects to store their unique ID within themselves (normally the ID is only stored in ReStore's internal structures)"

	self idInstVar: aSymbol
]

{ #category : 'accessing' }
SSWDBClassDefinition >> definedClass [
	^definedClass
]

{ #category : 'accessing' }
SSWDBClassDefinition >> definedClass: anObject [
	definedClass := anObject
]

{ #category : 'accessing' }
SSWDBClassDefinition >> idInstVar [
	^idInstVar
]

{ #category : 'accessing' }
SSWDBClassDefinition >> idInstVar: anObject [
	idInstVar := anObject
]

{ #category : 'accessing' }
SSWDBClassDefinition >> instVarDefinitions [
	^instVarDefinitions
]

{ #category : 'accessing' }
SSWDBClassDefinition >> instVarDefinitions: anObject [
	instVarDefinitions := anObject
]

{ #category : 'testing' }
SSWDBClassDefinition >> isEmpty [

	^self instVarDefinitions isEmpty and: [self idInstVar isNil]
]

{ #category : 'accessing' }
SSWDBClassDefinition >> name: aString [

	"Polymorphic with SSWDBTable"

	self tableName: aString
]

{ #category : 'accessing' }
SSWDBClassDefinition >> namespace [
	^namespace
]

{ #category : 'accessing' }
SSWDBClassDefinition >> namespace: anObject [

	"OPTIONAL:

	Define the namespace in which instances of definedClass will be stored.
	Normally this is nil, meaning the default namespace for the connection.
	Set to the name of another namespace on the same connection to store there instead (effectively the table's name becomes namespace.tableName)"

	namespace := anObject
]

{ #category : 'accessing' }
SSWDBClassDefinition >> tableName [
	^tableName
]

{ #category : 'accessing' }
SSWDBClassDefinition >> tableName: aString [

	"OPTIONAL:

	Define the name of the table in which instances of definedClass will be stored.
	Normally this is automatically generated based on the class's name."

	tableName := aString
]
