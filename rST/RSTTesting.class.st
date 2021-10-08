"
To test rST you need to run 2 squeaks in the same machine or in diferents machines.

If you run this examples in diferent machines, don't forget to change the IP address of the ""server"" squeak in RSTTesting class>>runClient

In server squeak:
	RSTTesting serverStartup.

In client squeak:
	RSTTesting runClient.

After run, in both squeaks:
	RSTTesting cleanup.

"
Class {
	#name : #RSTTesting,
	#superclass : #Object,
	#category : #'rST-Samples'
}

{ #category : #'address configuration' }
RSTTesting class >> clientPort [
	^ 8888
]

{ #category : #private }
RSTTesting class >> collectionToString: aCollection [
	| stream |
	stream _ String new writeStream.
	stream nextPutAll: '('.
	aCollection
		do: [:each | stream nextPutAll: each asString]
		separatedBy: [stream nextPutAll: ', '].
	stream nextPutAll: ')'.
	^ stream contents
]

{ #category : #'address configuration' }
RSTTesting class >> runClient [
	"Initialize an broker in the port 8888 and get a remote reference to a  
	Date named today"
	Transcript show: 'running client side rST example...';
		 cr.
	""
	RSTBroker
		startOnPort: self clientPort
		logging: false.
	""
	self runClientTodayTests.
	self runClientCollectionTests.
	self runClientTranscriptTests.
	self runClientPersonTests.
	self runClientPerformanceTests.
	""
	Transcript show: 'everything is ok!';
		 cr
]

{ #category : #'testing - client side' }
RSTTesting class >> runClientCollectionTests [
	"in this example remoteCollection receives 2 remote references to local  
	blocks, then the remote collection send #value: and #value to these  
	locals blocks"
	| remoteCollection localCollectionAsString remoteCollectionAsString remoteCollectionAsStringConverter |
	remoteCollection _ ('collection@' , self serverBrokerID) asRemoteObjectID asLocalObject.
	remoteCollectionAsStringConverter _ ('collectionAsStringConverter@' , self serverBrokerID) asRemoteObjectID asLocalObject.
	remoteCollectionAsString _ remoteCollectionAsStringConverter value.
	localCollectionAsString _ self collectionToString: remoteCollection.
	Transcript show: 'remoteCollection=';
		 show: localCollectionAsString;
		 cr.
	localCollectionAsString = remoteCollectionAsString
		ifFalse: [self error: 'something wrong!']
]

{ #category : #'testing - client side' }
RSTTesting class >> runClientPerformanceTests [
	| remoteToday localToday remoteTomorrow |
	localToday _ Date today.
	""
	remoteToday _ ('today@' , self serverBrokerID) asRemoteObjectID asLocalObject.
	remoteTomorrow _ remoteToday addDays: 1.
	MessageTally
		spyOn: [100
				timesRepeat: [remoteTomorrow subtractDate: localToday]]
]

{ #category : #'testing - client side' }
RSTTesting class >> runClientPersonTests [
	""
	| remotePerson1 remotePerson2 vc1 vc2 |
	remotePerson1 _ ('person1@' , self serverBrokerID) asRemoteObjectID asLocalObject.
	remotePerson2 _ ('person2@' , self serverBrokerID) asRemoteObjectID asLocalObject.
	""
	vc1 _ RSTPersonViewController on: remotePerson1.
	vc2 _ RSTPersonViewController on: remotePerson2.
	""
	vc1 test
		ifFalse: [self error: 'something wrong!'].
	vc2 test
		ifFalse: [self error: 'something wrong!']
]

{ #category : #'testing - client side' }
RSTTesting class >> runClientTodayTests [
	"Initialize an broker in the port 8888 and get a remote reference to a  
	Date named today"
	| remoteToday localToday remoteTomorrow localTomorrow elapsed |
	localToday _ Date today.
	localTomorrow _ localToday addDays: 1.
	""
	"you must change the IP if you run the example in diferents machines"
	remoteToday _ ('today@' , self serverBrokerID) asRemoteObjectID asLocalObject.
	remoteToday inspect.
	" 
	hash return an integer so i receive a copy and the #= is a local  
	message"
	localToday hash = remoteToday hash
		ifFalse: [self error: 'something wrong!'].
	" 
	remoteTomorrow is an remote object"
	remoteTomorrow _ remoteToday addDays: 1.
	remoteTomorrow isRemote
		ifFalse: [self error: 'something wrong!'].
	localTomorrow julianDayNumber = remoteTomorrow julianDayNumber
		ifFalse: [self error: 'something wrong!'].
	"pass a reference to a local object (localTomorrow)"
	elapsed _ remoteTomorrow subtractDate: localTomorrow.
	elapsed isRemote
		ifTrue: [self error: 'something wrong!'].
	elapsed isZero
		ifFalse: [self error: 'something wrong!']
]

{ #category : #'testing - client side' }
RSTTesting class >> runClientTranscriptTests [
	| remoteTranscript |
	remoteTranscript _ ('Transcript@' , self serverBrokerID) asRemoteObjectID asLocalObject.
	remoteTranscript show: 'everything is ok! (from client side)';
		 cr
]

{ #category : #'address configuration' }
RSTTesting class >> serverAddress [
	^ NetNameResolver localAddressString
]

{ #category : #'address configuration' }
RSTTesting class >> serverBrokerID [
	^ self serverAddress asString , ':' , self serverPort asString
]

{ #category : #'address configuration' }
RSTTesting class >> serverPort [
	^ 9999
]

{ #category : #'testing - server side' }
RSTTesting class >> serverStartup [
	"Initialize an broker in the port 9999 and export some objects for testing"
	| today collection |
	RSTBroker
		startOnPort: self serverPort
		logging: false.
	""
	RSTBroker instance export: Transcript named: 'Transcript'.
	today _ Date today.
	collection _ {1. 'aString'. #aSymbol. today}.
	RSTBroker instance export: today named: 'today'.
	RSTBroker instance export: collection named: 'collection'.
	RSTBroker instance
		export: [self collectionToString: collection]
		named: 'collectionAsStringConverter'.
	""
	RSTBroker instance
		export: (RSTPerson name: 'name1' eMail: 'eMail1')
		named: 'person1'.
	RSTBroker instance
		export: (RSTPerson name: 'name2' eMail: 'eMail2')
		named: 'person2'
]
