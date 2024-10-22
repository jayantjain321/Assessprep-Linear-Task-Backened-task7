class Ability
    include CanCan::Ability
  
    def initialize(user)
      # If user is logged in
      if user

        # Allow users can read comments
        can :read, Comment

        # Allow users to read projects
        can :read, Project 
        
        # Users can create comments and projects
        can :create, Comment
        can :create, Project

        # Users can update and destroy only their own comments and projects
        can [:update, :destroy], Comment, user_id: user.id
        can [:update, :destroy], Project, project_creator_id: user.id
      else
        # For guest users (not logged in)
        can :read, Comment
        can :read, Project
      end
    end
end
  