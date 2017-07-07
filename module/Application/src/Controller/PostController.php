<?php
namespace Application\Controller;

use Zend\Mvc\Controller\AbstractActionController;
use Zend\View\Model\ViewModel;
use Application\Entity\Post;
use Application\Form\PostForm;
use Application\Form\CommentForm;
use Application\Entity\Comment;

class PostController extends AbstractActionController
{
    /**
     * Entity manager.
     * @var Doctrine\ORM\EntityManager
     */
    private $entityManager;

    /**
     * Post manager.
     * @var Application\Service\PostManager
     */
    private $postManager;

    /**
     * Constructor is used for injecting dependencies into the controller.
     */
    public function __construct($entityManager, $postManager)
    {
        $this->entityManager = $entityManager;
        $this->postManager = $postManager;
    }

    /**
     * This action displays the "New Post" page. The page contains
     * a form allowing to enter post title, content and tags. When
     * the user clicks the Submit button, a new Post entity will
     * be created.
     */
    public function addAction()
    {
        // Create the form.
        $form = new PostForm();

        // Check whether this post is a POST request.
        if ($this->getRequest()->isPost()) {

            // Get POST data.
            $data = $this->params()->fromPost();

            // Fill form with data.
            $form->setData($data);
            if ($form->isValid()) {

                // Get validated form data.
                $data = $form->getData();

                // Use post manager service to add new post to database.
                $this->postManager->addNewPost($data);

                // Redirect the user to "index" page.
                return $this->redirect()->toRoute('application');
            }
        }

        // Render the view template.
        return new ViewModel([
            'form' => $form
        ]);
    }
    public function editAction()
   {
     // Create the form.
     $form = new PostForm();

     // Get post ID.
     $postId = $this->params()->fromRoute('id', -1);

     // Find existing post in the database.
     $post = $this->entityManager->getRepository(Post::class)
                 ->findOneById($postId);
     if ($post == null) {
       $this->getResponse()->setStatusCode(404);
       return;
     }

     // Check whether this post is a POST request.
     if ($this->getRequest()->isPost()) {

       // Get POST data.
       $data = $this->params()->fromPost();

       // Fill form with data.
       $form->setData($data);
       if ($form->isValid()) {

         // Get validated form data.
         $data = $form->getData();

         // Use post manager service to add new post to database.
         $this->postManager->updatePost($post, $data);

         // Redirect the user to "admin" page.
         return $this->redirect()->toRoute('application');
       }
     } else {
       $data = [
                'title' => $post->getTitle(),
                'content' => $post->getContent(),
                'tags' => $this->postManager->convertTagsToString($post),
                'status' => $post->getStatus()
             ];

       $form->setData($data);
     }

     // Render the view template.
     return new ViewModel([
             'form' => $form,
             'post' => $post
         ]);
   }
   public function deleteAction()
   {
     $postId = $this->params()->fromRoute('id', -1);

     $post = $this->entityManager->getRepository(Post::class)
                 ->findOneById($postId);
     if ($post == null) {
       $this->getResponse()->setStatusCode(404);
       return;
     }

     $this->postManager->removePost($post);

     // Redirect the user to "index" page.
     return $this->redirect()->toRoute('application');
   }
   public function viewAction()
   {
     $postId = $this->params()->fromRoute('id', -1);

      $post = $this->entityManager->getRepository(Post::class)
                ->findOneById($postId);


      if ($post == null) {
        $this->getResponse()->setStatusCode(404);
        return;
      }

      $commentCount = $this->postManager->getCommentCountStr($post);

      // Create the form.
      $form = new CommentForm();

      // Check whether this post is a POST request.
      if($this->getRequest()->isPost()) {

        // Get POST data.
        $data = $this->params()->fromPost();

        // Fill form with data.
        $form->setData($data);
        if($form->isValid()) {

          // Get validated form data.
          $data = $form->getData();

          // Use post manager service to add new comment to post.
          $this->postManager->addCommentToPost($post, $data);

          // Redirect the user again to "view" page.
          return $this->redirect()->toRoute('posts', ['action'=>'view', 'id'=>$postId]);
        }
      }

      // Render the view template.
      return new ViewModel([
        'post' => $post,
        'commentCount' => $commentCount,
        'form' => $form,
        'postManager' => $this->postManager
      ]);
  }
}
