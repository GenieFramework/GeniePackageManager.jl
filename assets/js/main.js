// const index = "/geniepackagemanager";
const indexlist = "/geniepackagemanager/list"
const packageManagerBaseUrl = "/geniepackagemanager/api/v1/"

/* const clickOutside = {
    beforeMount: (el, binding) => {
      el.clickOutsideEvent = event => {
        if (!(el == event.target || el.contains(event.target))) {
          binding.value();
        }
      };
      document.addEventListener("click", el.clickOutsideEvent);
    },
    unmounted: el => {
      document.removeEventListener("click", el.clickOutsideEvent);
    },
}; */

const { createApp, ref } = Vue;

const CustomButton = {
    props: ["label", "confirm_label", "cancel_label", "title"], 
    template: `
    <a v-if="!showConfirm" class="button secondary" v-on:click="showConfirm=true"><span data-tooltip :title="title">{{label}}</span></a>
    <a v-if="showConfirm" class="button alert" v-on:click="confirmClicked"><span data-tooltip>{{confirm_label}}</span></a>
    <a v-if="showConfirm" class="button secondary" v-on:click="showConfirm=false"><span data-tooltip>{{cancel_label}}</span></a>
    `,
    setup() {
        return {
            showConfirm: ref(false)
        }
    },
    methods: {
        confirmClicked(){
            this.$emit('confirm')
        }
    }
};

const app = createApp({
    data() {
        return {
            results: {},
            toAddPackage: "",
            dev: false,
            updateAll: false,
            isUpdateDisabled: true
        }
    },
    components: {

    },
    methods: {
        addPackage() {
            // if package contains @ split it by packageName and version
            if (this.toAddPackage.includes('@')) {
                const pkgSplit = this.toAddPackage.split("@");
                toAddPackage = pkgSplit[0];
                version = pkgSplit[1];

                axios.post(packageManagerBaseUrl+toAddPackage+"/"+version+"/add").then(response => {
                    console.log(response);
                    window.location.reload();
                })
            }
            else{
                const isValidUrl = urlString=> {
                    var urlPattern = new RegExp('^(https?:\\/\\/)?'+ // validate protocol
                  '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|'+ // validate domain name
                  '((\\d{1,3}\\.){3}\\d{1,3}))'+ // validate OR ip (v4) address
                  '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*'+ // validate port and path
                  '(\\?[;&a-z\\d%_.~+=-]*)?'+ // validate query string
                  '(\\#[-a-z\\d_]*)?$','i'); // validate fragment locator
                return !!urlPattern.test(urlString);
                }

                // if package name ends with '.jl' remove it
                // removed .jl so it's not recognized as a url by isValidUrl
                if (this.toAddPackage.endsWith(".jl")) {
                    this.toAddPackage = this.toAddPackage.slice(0, -3)
                }
                
                if (isValidUrl(this.toAddPackage)) {
                    repoLink = this.toAddPackage;
                    repoUrl = new URL(repoLink);

                    // if toAddPackage is a github/gitlab link
                    if (repoUrl.protocol == "https:" || repoUrl.protocol == "http:") {
                        repoUrl = repoUrl.toString();
                        urlSplit = repoUrl.split("/");
                        packageName = urlSplit[urlSplit.length-1];
                        orgName = urlSplit[urlSplit.length-2];

                        githost = urlSplit[urlSplit.length-3];
                        mygithostname = githost.split(".")[0];

                        githostname = ""

                        if (mygithostname == "github")
                            githostname = "github"
            
                        if(mygithostname == "gitlab")
                            githostname = "gitlab"
                        
                        if(mygithostname == "bitbucket")
                            githostname = "bitbucket"

                        pkgSplit = packageName.split(".")
                        pkgName = pkgSplit[0];
                        axios.post(packageManagerBaseUrl+ githostname + "/" + orgName+"/"+pkgName+"/addurl").then(response => {
                            console.log(response);
                            window.location.reload();
                        })
                    }
                }// if toAddPackage is a package name
                else {

                    if (this.dev == false) {
                        axios.post(packageManagerBaseUrl+this.toAddPackage+"/add").then(response => {
                            console.log(response);
                            window.location.reload();
                        })
                    }
                    else {
                        console.log("installing package" + this.toAddPackage + "in dev mode");
                        axios.post(packageManagerBaseUrl+this.toAddPackage+"/dev").then(response => {
                            console.log(response);
                            window.location.reload();
                        })
                    }
                }
            }
            
        },
        removePackage(packageName) {
            // if(confirm('are you sure you want to remove ' + packageName + '?'))
            axios.post(packageManagerBaseUrl+packageName+"/remove").then(response => {
                console.log(response);
                window.location.reload();
            })
        },
        updatePackage(packageName) {
            if(confirm('are you sure you want to update package: ' + packageName + '?'))
                axios.post(packageManagerBaseUrl+packageName+"/update").then(response => {
                    console.log(response);
                    window.location.reload();
                })
        },
        updateToggle() {
            if (this.updateAll == true) {
                this.isUpdateDisabled = false;
            }else{
                this.isUpdateDisabled = true;
            }
        },
        updateAllPackages() {
            if (this.isUpdateDisabled == false)
                // if(confirm('are you sure you want to update all packages?'))
                if(this.updateAll == true) {
                    this.isUpdateDisabled = false;
                    axios.get(packageManagerBaseUrl+"updateall").then(response => {
                        console.log(response);
                        window.location.reload();
                    })
                }
        }
    },
    mounted() {
        axios.get(indexlist).then(response => {
            console.log(response.data)
            obj = response.data
            const sorted = Object.keys(obj)
                .sort()
                .reduce((accumulator, key) => {
                    accumulator[key] = obj[key];

                    return accumulator;
                }, {});
            this.results = sorted
        })

    }
});

app.use(Quasar)

app.component('mygbutton', CustomButton)
//app.directive("clickOut", clickOutside)
app.mount('#app')


// app.mount('#app')
// app.use(FloatingVue)

// app.component('VDropdown', FloatingVue.Dropdown)
// app.directive('tooltip', FloatingVue.VTooltip)