# Definition

It is a service prepared to confirm the consistency of the election results with the official statements.

## Rating  Algorithm

1. The photos of the ballot box results uploaded to Twitter will be read automatically via the [Twitter service](../servers/twitter-service).
2. The results of the ballot boxes written in the tweet or the comment will be collected and the election result will be confirmed.
3. To eliminate election results incorrectly written by malicious people or software:
    1. The "Like" button will be used. The selection result statement that gets more likes will be considered true for the moment.
    2. Blacklists will be made (likes of users on the blacklist will not be taken into account)
    3. Whitelists will be made (likes of users in the whitelist will be considered valid)
    4. Automatic blacklist mechanism will work (Those who approve results other than those approved by the people on the white list will be automatically blacklisted)
    
# Requirements 

1. The photos of the signed minutes must be uploaded to Twitter with the hashtag [`#TR24Haziran2018`](https://twitter.com/hashtag/TR24Haziran2018?src=hash)

2. The numerical values in the report should be written in the tweet or as a comment in the following format:

        #TR24June2018 ballot box: 1234, aaa party: 45, bbb party 75, invalid: 3, total: 123
    

    
# Advantages

1. Twitter will operate here as a dispersed and public database. Thus, if anyone has doubts about whether our services are delivering correct results, they can copy our software and they can run it on their own computers. If anyone wants, they can prepare the software again and confirm it with the official results.

# Disadvantages

There is no downside for now.

# Road map

* Instead of a white list/black list, ballot box minutes will be scanned with image processing and the results will be entered into the system automatically.
