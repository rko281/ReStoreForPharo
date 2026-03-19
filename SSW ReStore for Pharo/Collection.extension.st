Extension { #name : 'Collection' }

{ #category : '*SSW ReStore for Pharo' }
Collection >> dbApproxSize [
	"db-prefixed copy of Porpoise implementation to avoid creating dependency.
	
	Private - Answer the approximate size of the receiver.
	Implementation Note: This does not have to be accurate, but it should be fast
	(i.e. don't calculate it by counting the receiver's elements).
	Dolphin defaults to 2, but we have such a wide messy hierarchy,
	it's easier for the subclasses that *don't* have a fast #size to override."

	^ self size
]
