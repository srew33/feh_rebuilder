# 项目结构

lib                                  
├─ core                              
│  ├─ enum                           枚举类
│  │  ├─ game_version.dart           游戏版本
│  │  ├─ move_type.dart              移动类型
│  │  ├─ page_state.dart             页面加载状态
│  │  ├─ person_type.dart            人物类型，未用到
│  │  ├─ series.dart                 人物出场游戏名
│  │  ├─ sort_key.dart               排序
│  │  ├─ stats.dart                  属性名
│  │  └─ weapon_type.dart            武器类型
│  ├─ filterChain                    
│  │  └─ filter_chain.dart           过滤链，用于检索数据
│  ├─ filters                        
│  │  ├─ filter.dart                 过滤器的父类
│  │  ├─ person.dart                 人物过滤器
│  │  └─ skill.dart                  技能过滤器
│  ├─ exceptions.dart                自定义的异常类
│  └─ platform_info.dart             检测运行平台，不依赖dartio
├─ home_screens                      主页的几个页面
│  ├─ cubit                          
│  │  └─ screens_cubit.dart          主页的cubit，用来切换页面
│  ├─ favourites                     收藏页
│  │  ├─ bloc                        
│  │  │  ├─ favscreen_bloc.dart      
│  │  │  ├─ favscreen_event.dart     
│  │  │  └─ favscreen_state.dart     
│  │  └─ page.dart                   
│  ├─ home                           人物页
│  │  ├─ bloc                        
│  │  │  ├─ home_bloc.dart           
│  │  │  ├─ home_event.dart          
│  │  │  └─ home_state.dart          
│  │  └─ page.dart                   
│  ├─ others                         其他页
│  │  └─ page.dart                   
│  └─ page.dart                      
├─ models                            数据模型
│  ├─ cloud_object                   网络服务的表模型
│  │  ├─ build_table.dart            
│  │  ├─ favorite_table.dart         
│  │  ├─ like_table.dart             
│  │  └─ update_table.dart           
│  ├─ move_type                      移动类别
│  │  ├─ give.dart                   
│  │  ├─ move_type.dart              
│  │  └─ use.dart                    
│  ├─ person                         人物
│  │  ├─ dragonflowers.dart          
│  │  ├─ growth_rates.dart           
│  │  ├─ json_person.dart            
│  │  ├─ legendary.dart              
│  │  ├─ person.dart                 
│  │  ├─ skills.dart                 
│  │  └─ stats.dart                  
│  ├─ personBuild                    build模型
│  │  └─ person_build.dart           
│  ├─ resplendent_hero               神装英雄模型，未用到
│  │  └─ resplendent_hero.dart       
│  ├─ skill                          技能模型
│  │  ├─ json_skill.dart             
│  │  └─ skill.dart                  
│  ├─ skill_accessory                圣印模型，未用到
│  │  └─ skill_accessory.dart        
│  ├─ weapon_refine                  武器锻造
│  │  ├─ give.dart                   
│  │  └─ weapon_refine.dart          
│  └─ weapon_type                    武器类别
│     └─ weapon_type.dart            
├─ pages                             除主页外的页面
│  ├─ build_share                    build分享页面
│  │  ├─ bloc                        
│  │  │  ├─ buildshare_bloc.dart     
│  │  │  ├─ buildshare_event.dart    
│  │  │  └─ buildshare_state.dart    
│  │  └─ page.dart                   
│  ├─ hero_detail                    人物详情页
│  │  ├─ bloc                        
│  │  │  ├─ herodetail_bloc.dart     
│  │  │  ├─ herodetail_event.dart    
│  │  │  └─ herodetail_state.dart    
│  │  └─ page.dart                   
│  └─ skill_select                   技能选择/浏览页面
│     ├─ bloc                        
│     │  ├─ skillselect_bloc.dart    
│     │  ├─ skillselect_event.dart   
│     │  └─ skillselect_state.dart   
│     └─ page.dart                   
├─ repositories                      数据层
│  ├─ config_cubit                   全局设置的cubit
│  │  ├─ config_cubit.dart           
│  │  └─ config_state.dart           
│  ├─ api.dart                       网络请求
│  ├─ data_provider.dart             数据库
│  ├─ data_table.dart                数据表
│  └─ repository.dart                数据操作封装
├─ styles                            自定义的style
│  └─ text_styles.dart               
├─ widgets                           自定义的widget
│  ├─ filter_drawer.dart             主页人物界面的drawer
│  ├─ jumpable_listview.dart         可跳转的listview
│  ├─ person_tile.dart               人物的listtile，用于主页
│  ├─ picker.dart                    翻译、性格等bottomsheet弹出的选择组件
│  ├─ skill_tile.dart                技能的listtile，用于技能显示
│  ├─ uni_dialog.dart                dialog的自定义封装，提供统一的一些样式
│  ├─ uni_image.dart                 图片显示的自定义组件，不依赖dartio，具有网络缓存功能
│  └─ update_dialog.dart             其他页面弹出的升级对话框
├─ env_provider.dart                 全局变量
├─ i18n.dart                         翻译
├─ main.dart                         
└─ utils.dart                        一些工具函数
