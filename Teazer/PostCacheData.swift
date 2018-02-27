//
//  PostCacheData.swift
//  Teazer
//
//  Created by Faraz Habib on 03/12/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation

class PostCacheData {
    
    //add others profile video
    
    static let shared = PostCacheData()
    
    private var myProfilePosts = [Post]()
    private var othersProfilePosts = [Int:[Post]]()
    
    var posts = [Post]()
    private var homePageVideosIndex = [Int]()
    private var mostPopularVideosIndex = [Int]()
    private var categoryVideosIndex = [[Int:[Int]]]()
    private var myCategoryVideosIndex = [[String:[Int]]]()
    private var featuredVideosIndex = [Int]()
    private var profileVideosIndex = [Int]()
    private var othersProfileVideosIndex = [[Int:[Int]]]()
    
    //MARK:- Profile posts
    func resetMyProfileCache() {
//        myProfilePosts = [Post]()
    }
    
    func resetOthersProfileCache(postOwnerId:Int?) {
//        guard let userId = postOwnerId else {
//            return
//        }
        
    }
    
    func saveMyProfilePost(post:Post) {
//        myProfilePosts.append(post)
    }
    
    func saveOthersProfilePost(post:Post) {
//        guard let postOwnerId = post.postOwner?.userId else {
//            return
//        }
//        
//        if var cachedPosts = othersProfilePosts[postOwnerId] {
//            cachedPosts.append(post)
//            othersProfilePosts[postOwnerId] = cachedPosts
//        } else {
//            othersProfilePosts[postOwnerId] = [post]
//        }
    }
    
    
    
    // <<<<< -------------------------------------------------------------- >>>>>
    func updatePost(_ video:Post, index:Int) {
        if posts.count >= index {
            posts[index] = video
        }
    }
    
    // MARK: - Save posts methods
    func saveHomePageVideos(videos:[Post]) {
        for video in videos {
            var index = posts.index(where: { (postObj) -> Bool in
                return video.postId == postObj.postId
            })
            
            if index != nil {
                posts[index!] = video
            } else {
                index = posts.count
                posts.append(video)
                homePageVideosIndex.append(index!)
            }
            
            posts[index!].index = index!
        }
    }
    
    func saveHomePageVideos(videos:[Post], withCompletionHandler handler:() -> Void) {
        for video in videos {
            var index = posts.index(where: { (postObj) -> Bool in
                return video.postId == postObj.postId
            })
            
            if index != nil {
                posts[index!] = video
            } else {
                index = posts.count
                posts.append(video)
                homePageVideosIndex.append(index!)
            }
            
            posts[index!].index = index!
        }
        
        handler()
    }
    
    // Video will just get updated
    func saveHomePageVideo(video:Post) -> Int {
        var index = posts.index(where: { (postObj) -> Bool in
            return video.postId == postObj.postId
        })
        
        if index != nil {
            posts[index!] = video
        } else {
            index = posts.count
            posts.append(video)
            homePageVideosIndex.append(index!)
        }
        
        posts[index!].index = index!
        return index!
    }
    
    // Video will come on top
    func saveNewOrEditedHomePageVideo(video:Post) -> Int {
        var index = posts.index(where: { (postObj) -> Bool in
            return video.postId == postObj.postId
        })
        
        if index != nil {
            posts[index!] = video
            let postIndex = homePageVideosIndex.index(where: { (ind) -> Bool in
                return ind == index
            })
            if postIndex != nil {
                homePageVideosIndex.remove(at: postIndex!)
                homePageVideosIndex.insert(index!, at: 0)
            } else {
                homePageVideosIndex.insert(index!, at: 0)
            }
        } else {
            index = posts.count
            posts.append(video)
            profileVideosIndex.insert(index!, at: 0)
            homePageVideosIndex.insert(index!, at: 0)
        }
        
        posts[index!].index = index!
        return index!
    }
    
    func saveMostPopularVideos(videos:[Post]) {
        for video in videos {
            var index = posts.index(where: { (postObj) -> Bool in
                return video.postId == postObj.postId
            })
            
            if index != nil {
                posts[index!] = video
                
                let postIndex = mostPopularVideosIndex.index(where: { (ind) -> Bool in
                    return ind == index
                })
                if postIndex == nil {
                    mostPopularVideosIndex.append(index!)
                }
            } else {
                index = posts.count
                posts.append(video)
                
            }

            posts[index!].index = index!
        }
    }
    
    func saveMyCategoryVideosIndexVideos(categoryName:String, videos:[Post]) {
        for video in videos {
            var index = posts.index(where: { (postObj) -> Bool in
                return video.postId == postObj.postId
            })
            
            if index != nil {
                posts[index!] = video
                
                let catIndex = myCategoryVideosIndex.index(where: { (obj) -> Bool in
                    return obj.keys.first == categoryName
                })
                
                if catIndex != nil {
                    var postIndexList = myCategoryVideosIndex[catIndex!].values.first!
                    let constainsIndex = postIndexList.index(where: { (value) -> Bool in
                        return value == index
                    })
                    if constainsIndex == nil {
                        postIndexList.append(index!)
                        myCategoryVideosIndex[catIndex!][categoryName] = postIndexList
                    }
                } else {
                    let param:[String:[Int]] = [
                        categoryName    :   [index!]
                    ]
                    myCategoryVideosIndex.append(param)
                }
            } else {
                index = posts.count
                posts.append(video)
                
                let catIndex = myCategoryVideosIndex.index(where: { (obj) -> Bool in
                    return obj.keys.first == categoryName
                })
                
                if catIndex != nil {
                    var postIndexList = myCategoryVideosIndex[catIndex!].values.first!
                    let constainsIndex = postIndexList.index(where: { (value) -> Bool in
                        return value == index
                    })
                    if constainsIndex == nil {
                        postIndexList.append(index!)
                        myCategoryVideosIndex[catIndex!][categoryName] = postIndexList
                    }
                } else {
                    let param:[String:[Int]] = [
                        categoryName    :   [index!]
                    ]
                    myCategoryVideosIndex.append(param)
                }
            }
            
            posts[index!].index = index!
        }
    }
    
    func saveFeaturedVideosIndexVideos(videos:[Post]) {
        for video in videos {
            var index = posts.index(where: { (postObj) -> Bool in
                return video.postId == postObj.postId
            })
            
            if index != nil {
                posts[index!] = video
                
                let postIndex = featuredVideosIndex.index(where: { (ind) -> Bool in
                    return ind == index
                })
                if postIndex == nil {
                    featuredVideosIndex.append(index!)
                }
            } else {
                index = posts.count
                posts.append(video)
                featuredVideosIndex.append(index!)
            }
            
            posts[index!].index = index!
        }
    }
    
    func saveFeaturedVideosIndexVideo(video:Post) {
        var index = posts.index(where: { (postObj) -> Bool in
            return video.postId == postObj.postId
        })
        
        if index != nil {
            posts[index!] = video
            
            let postIndex = featuredVideosIndex.index(where: { (ind) -> Bool in
                return ind == index
            })
            if postIndex == nil {
                featuredVideosIndex.append(index!)
            }
        } else {
            index = posts.count
            posts.append(video)
            featuredVideosIndex.append(index!)
        }
        
        posts[index!].index = index!
    }
    
    func saveProfileVideosIndexVideos(videos:[Post]) {
        profileVideosIndex = [Int]()
        
        for video in videos {
            var index = posts.index(where: { (postObj) -> Bool in
                return video.postId == postObj.postId
            })
            
            if index != nil {
                posts[index!] = video
                
                let postIndex = profileVideosIndex.index(where: { (value) -> Bool in
                    return value == index
                })
                
                if postIndex == nil {
                    profileVideosIndex.append(index!)
                }
                
            } else {
                index = posts.count
                posts.append(video)
                profileVideosIndex.append(index!)
            }
            
            posts[index!].index = index!
        }
    }
    
    func saveOthersProfileVideosIndexVideos(userId:Int, videos:[Post]) {
        for video in videos {
            var index = posts.index(where: { (postObj) -> Bool in
                return video.postId == postObj.postId
            })
            
            if index != nil {
                posts[index!] = video
                
                let userIndex = othersProfileVideosIndex.index(where: { (videoObj) -> Bool in
                    return videoObj.keys.first == userId
                })
                
                if userIndex != nil {
                    var postIndexList = othersProfileVideosIndex[userIndex!].values.first!
                    let constainsIndex = postIndexList.index(where: { (value) -> Bool in
                        return value == index
                    })
                    
                    if constainsIndex == nil {
                        postIndexList.append(index!)
                    }
                    othersProfileVideosIndex[userIndex!][userId] = postIndexList
                } else {
                    let userIndexDict = [
                        userId    :   [index!]
                    ]
                    othersProfileVideosIndex.append(userIndexDict)
                }
            } else {
                index = posts.count
                posts.append(video)
                
                let userIndexDict = [
                    userId    :   [index!]
                ]
                othersProfileVideosIndex.append(userIndexDict)
            }
            
            posts[index!].index = index!
        }
    }
    
    func savePostsIndexToCategoryList(_ categoryId:Int, videos:[Post]) {
        for video in videos {
            var index = posts.index(where: { (postObj) -> Bool in
                return video.postId == postObj.postId
            })
            
            if index != nil {
                posts[index!] = video
                
                let catIndex = categoryVideosIndex.index(where: { (value) -> Bool in
                    return value.keys.first == categoryId
                })
                
                if catIndex != nil {
                    var postIndexList = categoryVideosIndex[catIndex!].values.first!
                    let constainsIndex = postIndexList.index(where: { (value) -> Bool in
                        return value == index
                    })
                    
                    if constainsIndex == nil {
                        postIndexList.append(index!)
                    }
                    categoryVideosIndex[catIndex!][categoryId] = postIndexList
                } else {
                    let userIndexDict = [
                        categoryId    :   [index!]
                    ]
                    categoryVideosIndex.append(userIndexDict)
                }
            } else {
                index = posts.count
                posts.append(video)
                
                let userIndexDict = [
                    categoryId    :   [index!]
                ]
                categoryVideosIndex.append(userIndexDict)
            }
            
            posts[index!].index = index!
        }
    }
    
    // MARK: - fetch posts methods
    func fetchPostsForUserId(_ userId:Int) -> [Post] {
        let list = posts.filter { (post) -> Bool in
            return post.postOwner?.userId == userId
        }
        return list
    }
    
    func fetchHomePageVideosIndex() -> [Int] {
        return homePageVideosIndex
    }
    
    func fetchMostPopularVideosIndex() -> [Int] {
        return mostPopularVideosIndex
    }
    
    func fetchCategoryVideos(categoryId:Int) -> [Int] {
        let categoryIndex = categoryVideosIndex.index(where: { (categoryObj) -> Bool in
            return categoryObj.keys.first == categoryId
        })
        
        if categoryIndex != nil {
            return categoryVideosIndex[categoryIndex!].values.first!
        }

        return [Int]()
    }
    
    func fetchMyCategoryVideos() -> [[String:[Int]]] {
        return myCategoryVideosIndex
    }
    
    func fetchProfileVideosIndex() -> [Int] {
        return profileVideosIndex
    }
    
    func fetchOthersProfileVideosIndex(userId:Int) -> [Int] {
        let userIndex = othersProfileVideosIndex.index(where: { (videoObj) -> Bool in
            return videoObj.keys.first == userId
        })
        
        if userIndex != nil {
            if let indexList = othersProfileVideosIndex[userIndex!].values.first {
                return indexList
            }
        }
        return [Int]()
    }
    
    func fetchFeaturedVideosIndex() -> [Int] {
        return featuredVideosIndex
    }
    
    //MARK: - Delete post
    func deletePost(postIndex:Int, completionBlock:@escaping () -> Void) {
        removeIndexFromHomeVideos(postIndex: postIndex)
        removeIndexFromPopularVideos(postIndex: postIndex)
        removeIndexFromFeaturedVideos(postIndex: postIndex)
        removeIndexFromProfileVideos(postIndex: postIndex)
        
        let post = posts[postIndex]
        if let list = post.categories {
            removeIndexFromCategoryVideos(categoryList: list, postIndex: post.index)
        }
        posts[postIndex].isDeleted = true
        
        completionBlock()
    }
    
    func deletePostsList(list:[Post], completionBlock:@escaping () -> Void) {
        for post in list {
            removeIndexFromHomeVideos(postIndex: post.index)
            removeIndexFromPopularVideos(postIndex: post.index)
            removeIndexFromFeaturedVideos(postIndex: post.index)
            removeIndexFromProfileVideos(postIndex: post.index)
            
            if let catList = post.categories {
                removeIndexFromCategoryVideos(categoryList: catList, postIndex: post.index)
            }
            posts[post.index].isDeleted = true
        }
        
        completionBlock()
    }
    
    func hidePost(post:Post, completionBlock:@escaping () -> Void) {        
        removeIndexFromHomeVideos(postIndex: post.index)
        removeIndexFromPopularVideos(postIndex: post.index)
        removeIndexFromFeaturedVideos(postIndex: post.index)
        
        if let list = post.categories {
            removeIndexFromCategoryVideos(categoryList: list, postIndex: post.index)
        }
        posts[post.index].isDeleted = true
        
        completionBlock()
    }
    
    func removeIndexFromHomeVideos(postIndex:Int) {
        let videoIndex = homePageVideosIndex.index { (value) -> Bool in
            return value == postIndex
        }
        if videoIndex != nil {
            homePageVideosIndex.remove(at: videoIndex!)
        }
    }
    
    func removeIndexFromPopularVideos(postIndex:Int) {
        let videoIndex = mostPopularVideosIndex.index { (index) -> Bool in
            return index == postIndex
        }
        if videoIndex != nil {
            mostPopularVideosIndex.remove(at: videoIndex!)
        }
    }
    
    func removeIndexFromCategoryVideos(categoryList:[Category], postIndex:Int) {
        for category in categoryList {
            let categoryIndex = categoryVideosIndex.index(where: { (categoryObj) -> Bool in
                return categoryObj.keys.first == category.categoryId
            })
            
            if categoryIndex != nil {
                var postCategoryIndexList = categoryVideosIndex[categoryIndex!].values.first!
                let constainsIndex = postCategoryIndexList.index(where: { (value) -> Bool in
                    return value == postIndex
                })
                
                if constainsIndex != nil {
                    postCategoryIndexList.remove(at: constainsIndex!)
                }
                categoryVideosIndex[categoryIndex!][category.categoryId!] = postCategoryIndexList
            }
            
            let myCategoryIndex = myCategoryVideosIndex.index(where: { (categoryObj) -> Bool in
                return categoryObj.keys.first == category.categoryName
            })
            
            if myCategoryIndex != nil {
                var postCategoryIndexList = myCategoryVideosIndex[myCategoryIndex!].values.first!
                let constainsIndex = postCategoryIndexList.index(where: { (value) -> Bool in
                    return value == postIndex
                })
                
                if constainsIndex != nil {
                    postCategoryIndexList.remove(at: constainsIndex!)
                }
                myCategoryVideosIndex[myCategoryIndex!][category.categoryName!] = postCategoryIndexList
            }
        }
    }
    
    func removeIndexFromFeaturedVideos(postIndex:Int) {
        let videoIndex = featuredVideosIndex.index { (index) -> Bool in
            return index == postIndex
        }
        if videoIndex != nil {
            featuredVideosIndex.remove(at: videoIndex!)
        }
    }
    
    func removeIndexFromProfileVideos(postIndex:Int) {
        let videoIndex = profileVideosIndex.index { (index) -> Bool in
            return index == postIndex
        }
        
        if videoIndex != nil {
            profileVideosIndex.remove(at: videoIndex!)
        }
    }
}
