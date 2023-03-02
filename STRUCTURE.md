lib                              
├─ core                          
│  ├─ build_checker              build检查，用于在上传时进行检查
│  │  └─ build_checker.dart      
│  ├─ enum                       枚举类
│  │  ├─ game_version.dart       
│  │  ├─ languages.dart          
│  │  ├─ move_type.dart          
│  │  ├─ page_state.dart         
│  │  ├─ person_type.dart        
│  │  ├─ series.dart             
│  │  ├─ sort_key.dart           
│  │  ├─ stats.dart              
│  │  └─ weapon_type.dart        
│  ├─ filterChain                过滤链，用于检索数据
│  │  └─ filter_chain.dart       
│  ├─ filters                    过滤器
│  │  ├─ filter.dart             
│  │  ├─ person.dart             
│  │  └─ skill.dart              
│  ├─ exceptions.dart            自定义的异常类
│  └─ platform_info.dart         检测运行平台，不依赖dartio
├─ models                        数据模型
│  ├─ arena_team                 
│  │  └─ arena_team.dart         
│  ├─ base                       
│  │  ├─ person_base.dart        
│  │  └─ skill_base.dart         
│  ├─ build_share                
│  │  ├─ base.dart               
│  │  ├─ build_table.dart        
│  │  ├─ favorite_table.dart     
│  │  ├─ likes.dart              
│  │  ├─ net_tags.dart           
│  │  └─ update_table.dart       
│  ├─ move_type                  
│  │  ├─ give.dart               
│  │  ├─ move_type.dart          
│  │  └─ use.dart                
│  ├─ person                     
│  │  ├─ dragonflowers.dart      
│  │  ├─ growth_rates.dart       
│  │  ├─ json_person.dart        
│  │  ├─ legendary.dart          
│  │  ├─ person.dart             
│  │  ├─ skills.dart             
│  │  └─ stats.dart              
│  ├─ personBuild                
│  │  └─ person_build.dart       
│  ├─ resplendent_hero           
│  │  └─ resplendent_hero.dart   
│  ├─ skill                      
│  │  ├─ json_skill.dart         
│  │  └─ skill.dart              
│  ├─ skill_accessory            
│  │  └─ skill_accessory.dart    
│  ├─ sky_castle                 
│  │  └─ field.dart              
│  ├─ weapon_refine              
│  │  ├─ give.dart               
│  │  └─ weapon_refine.dart      
│  └─ weapon_type                
│     └─ weapon_type.dart        
├─ my_18n                        翻译组件
│  ├─ extension.dart             
│  └─ widget.dart                
├─ pages                        页面 
│  ├─ build_share                
│  │  ├─ controller.dart         
│  │  ├─ model.dart              
│  │  └─ ui.dart                 
│  ├─ fav                        
│  │  ├─ body                    
│  │  │  ├─ first                
│  │  │  │  ├─ controller.dart   
│  │  │  │  ├─ favfixedbar.dart  
│  │  │  │  ├─ model.dart        
│  │  │  │  └─ ui.dart           
│  │  │  └─ second               
│  │  │     ├─ controller.dart   
│  │  │     ├─ model.dart        
│  │  │     └─ ui.dart           
│  │  └─ ui.dart                 
│  ├─ hero_detail                
│  │  ├─ widgets                 
│  │  │  ├─ attr_tile.dart       
│  │  │  ├─ circle_btn.dart      
│  │  │  ├─ desc_widget.dart     
│  │  │  ├─ skill_tile.dart      
│  │  │  └─ tiles.dart           
│  │  ├─ controller.dart         
│  │  ├─ model.dart              
│  │  └─ ui.dart                 
│  ├─ home                       
│  │  ├─ controller.dart         
│  │  ├─ model.dart              
│  │  └─ ui.dart                 
│  ├─ others                     
│  │  └─ ui.dart                 
│  └─ skills                     
│     ├─ controller.dart         
│     ├─ model.dart              
│     └─ ui.dart                 
├─ repositories                  数据层
│  ├─ net_service                
│  │  ├─ cloud_object            
│  │  │  ├─ base.dart            
│  │  │  ├─ build_table.dart     
│  │  │  ├─ favorite_table.dart  
│  │  │  ├─ likes.dart           
│  │  │  ├─ tags.dart            
│  │  │  └─ update_table.dart    
│  │  ├─ base_api.dart           
│  │  └─ service.dart            
│  ├─ config_provider.dart       
│  ├─ data_provider.dart         
│  ├─ data_table.dart            
│  ├─ repository.dart            
│  └─ repo_provider.dart         
├─ styles                        自定义的style
│  └─ text_styles.dart           
├─ widgets                       自定义的widget
│  ├─ filter_drawer              
│  │  ├─ controller.dart         
│  │  ├─ filter_drawer.dart      
│  │  └─ model.dart              
│  ├─ hero_avatar.dart           
│  ├─ jumpable_listview.dart     
│  ├─ person_tile.dart           
│  ├─ picker.dart                
│  ├─ skill_tile.dart            
│  ├─ uni_dialog.dart            
│  ├─ uni_image.dart             
│  └─ update_dialog.dart         
├─ env_provider.dart             全局变量
├─ main.dart                     
└─ utils.dart                    一些工具函数
