Class {
	#name : 'ConcreteB',
	#superclass : 'AbstractB',
	#instVars : [
		'b'
	],
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
ConcreteB class >> reStoreDefinition [

	^super reStoreDefinition
		define: #b as: String;
		define: #reference as: ConcreteReferenceB;
		yourself
]
