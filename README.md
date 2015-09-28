# A-ViewContainer
Multiple controller cards container

###### Default style:
![demo1](https://raw.githubusercontent.com/Animaxx/A-ViewContainer/master/demo/viewContainer_demo1.gif)

###### Extra animation:
![demo2](https://raw.githubusercontent.com/Animaxx/A-ViewContainer/master/demo/viewContainer_demo2.gif)

# Usage
```Objective-C
// If the view is A_MultipleViewContainer already, then you don't need to call InstallTo method.
A_MultipleViewContainer *centerView = [A_MultipleViewContainer A_InstallTo:self.view];
[centerView A_AddChild:[DemoLabelViewController createWithNumber:0]];
[centerView A_AddChild:[DemoLabelViewController createWithNumber:1]];
[centerView A_AddChild:[DemoLabelViewController createWithNumber:2]];
[centerView A_AddChild:[DemoLabelViewController createWithNumber:3]];
[centerView A_Display];
```
