- 参考文档 https://www.atlassian.com/git/tutorials/dotfiles

工作设备和自己的电脑环境有些出入，切换的时候总有一些不顺手，每一次重新配置都花费了大量的时间，因此想要找到一个集中管理配置文件的方法，以后在不同的平台上可以快速的切换，方便快捷。

git 管理的方式可以满足基本的需要，另外发现 git bare 仓库可以将文件分散在不同的位置，bare 仓库中只记录变动，这种方式不需要统一的管理，更加的方便。

**疑问：仓库里没有文件的话，那当新用户拉取代码的时候他就只能得到 git 的元数据，怎么恢复呢？**

bare 仓库与普通仓库的区别
* bare 仓库：只有 Git 的元数据（如提交历史、分支信息、标签等），没有实际的代码文件。它只是存储所有的版本控制信息。
* 普通仓库：包含 . git 文件夹和一个实际的工作目录（即你平时写代码的地方，包含源代码文件）。

当新用户从 bare Git 仓库拉取代码时，Git 会：
* 创建一个新的本地仓库（包含 . git 目录和工作目录）。
* 从 bare 仓库中拉取所有的元数据。
* 自动恢复工作目录中的文件，并将其置于最新的提交状态。

## Git bare 仓库创建
1. 创建仓库
```
mkdir $HOME/.dotfiles
git init --bare $HOME/.dotfiles
```
创建一个名为 dot 的快捷命令，方便你直接在终端中使用它来管理 dotfiles。可以在 .bashrc 或 .zshrc 中添加如下内容：
```
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```
2. 之后就可以将 dotfiles 添加到 bare 仓库。
```
dot checkout
dot config --local status.showUntrackedFiles no  # 忽略未跟踪文件的状态
```
例如添加已经存在的`.zshrc`文件
```
dot add .zshrc
dot commit -m "Add .zshrc"
```
3. 将更改推送到远程仓库
如果有一个远程 bare 仓库（例如 GitHub），你可以将当前 bare 仓库连接到远程仓库：
```
dot remote add origin https://github.com/hanwinbi/dotfiles.git
dot push -u origin master
```
### 在新系统上克隆 dotfiles
当需要在新机器上设置 dotfiles 时，克隆 bare 仓库：
```
git clone --bare https://github.com/hanwinbi/dotfiles.git $HOME/.dotfiles
```

然后，设置 Git 的工作树，所有的配置文件就和其他系统上保持一致了：
```
dot checkout
```

### 其他操作：移除环境
```
rm -rf ~/.oh-my-zsh
rm ~/.zshrc
mv ~/.zshrc.pre-oh-my-zsh ~/.zshrc 2>/dev/null
```

