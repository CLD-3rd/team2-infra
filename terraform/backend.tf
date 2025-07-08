terraform { 
  cloud { 
    organization = "team2-SaveMyPodo" 

    workspaces { 
      name = "team2-infra-dev" 
    } 
  } 
}