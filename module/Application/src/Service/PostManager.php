<?php
namespace Application\Service;

use Application\Entity\Post;
use Application\Entity\Comment;
use Application\Entity\Tag;
use Zend\Filter\StaticFilter;

// The PostManager service is responsible for adding new posts.
class PostManager
{
  /**
   * Doctrine entity manager.
   * @var Doctrine\ORM\EntityManager
   */
  private $entityManager;

  // Constructor is used to inject dependencies into the service.
  public function __construct($entityManager)
  {
    $this->entityManager = $entityManager;
  }

  // This method adds a new post.
  public function addNewPost($data)
  {
    // Create new Post entity.
    $post = new Post();
    $post->setTitle($data['title']);
    $post->setContent($data['content']);
    $post->setStatus($data['status']);
    $currentDate = date('Y-m-d H:i:s');
    $post->setDateCreated($currentDate);

    // Add the entity to entity manager.
    $this->entityManager->persist($post);

    // Add tags to post
    $this->addTagsToPost($data['tags'], $post);

    // Apply changes to database.
    $this->entityManager->flush();
  }

  // Adds/updates tags in the given post.
  private function addTagsToPost($tagsStr, $post)
  {
    // Remove tag associations (if any)
    $tags = $post->getTags();
    foreach ($tags as $tag) {
      $post->removeTagAssociation($tag);
    }

    // Add tags to post
    $tags = explode(',', $tagsStr);
    foreach ($tags as $tagName) {

      $tagName = StaticFilter::execute($tagName, 'StringTrim');
      if (empty($tagName)) {
        continue;
      }

      $tag = $this->entityManager->getRepository(Tag::class)
                 ->findOneByName($tagName);
      if ($tag == null)
        $tag = new Tag();
      $tag->setName($tagName);
      $tag->addPost($post);

      $this->entityManager->persist($tag);

      $post->addTag($tag);
    }
  }

  public function updatePost($post, $data)
  {
      $post->setTitle($data['title']);
      $post->setContent($data['content']);
      $post->setStatus($data['status']);

      // Add tags to post
      $this->addTagsToPost($data['tags'], $post);

      // Apply changes to database.
      $this->entityManager->flush();
  }

  public function convertTagsToString($post)
  {
      $tags = $post->getTags();
      $tagCount = count($tags);
      $tagsStr = '';
      $i = 0;
      foreach ($tags as $tag) {
          $i ++;
          $tagsStr .= $tag->getName();
          if ($i < $tagCount)
              $tagsStr .= ', ';
      }

      return $tagsStr;
  }
  public function removePost($post)
  {
    // Remove associated comments
    $comments = $post->getComments();
    foreach ($comments as $comment) {
     $this->entityManager->remove($comment);
    }

    // Remove tag associations (if any)
    $tags = $post->getTags();
    foreach ($tags as $tag) {
     $post->removeTagAssociation($tag);
    }

    $this->entityManager->remove($post);

    $this->entityManager->flush();
  }

  public function getCommentCountStr($post)
  {
      $commentCount = count($post->getComments());
      if ($commentCount == 0)
          return 'No comments';
      else if ($commentCount == 1)
          return '1 comment';
      else
          return $commentCount . ' comments';
  }

  public function addCommentToPost($post, $data)
  {
      // Create new Comment entity.
      $comment = new Comment();
      $comment->setPost($post);
      $comment->setAuthor($data['author']);
      $comment->setContent($data['comment']);
      $currentDate = date('Y-m-d H:i:s');
      $comment->setDateCreated($currentDate);

      // Add the entity to entity manager.
      $this->entityManager->persist($comment);

      // Apply changes.
      $this->entityManager->flush();
  }
}
