#~ /bin/bash
## Agha Naser Programme #########
## By: Rojin Ebrahimi          ##
## Date: 2022-08-08            ##
#################################

# -- Greetings ----------------------------------------------------
greeting() {
    echo -e "\nWell, you are so welcome to my store dear ${customer_name}!"
    echo $1
}


# -- Ask for customer's name --------------------------------------
for (( ; ; ))
do
    read -p "Hey! I'd be glad to know your name: " customer_name
    if [[ ! "x$customer_name" = "x" ]]
    then
        break
    fi
done
greeting


# -- Definition of goods ------------------------------------------
declare -A goods
goods=( ["Pen"]=8000 ["Notebook"]=20000 ["Pencil"]=6000 ["A4_paper"]=90000 ) 


# -- Definition of purchases --------------------------------------
declare -A customer_purchases
customer_purchases=()


# -- Define loop flag and summation -------------------------------
continue_shopping=1
total_purchase_price=0 


# -- Show total purchase price ------------------------------------
show_total_price() {
    echo "Total payment: $1"
}


# -- Discount -----------------------------------------------------
discount() {
    discount_percent=0.05
    if [[ $1 -ge 100000 ]]
    then
        let total_purchase_price-=$(awk "BEGIN {print ($1 * $discount_percent)}")
        echo "Final payment: $total_purchase_price"
    else
        return
    fi
}


# -- Show customer purchases --------------------------------------
show_purchase() {
    echo "${!customer_purchases[*]}"
    echo -e "${customer_purchases[*]}" | tr ' ' '\t'
}


# -- Purchase goods -----------------------------------------------
purchase() {
    item_total_price=0
    item_price=$1
    item=$2
    
    read -p "How many of the item is needed? " item_number
    let item_total_price+=$(( $item_price * $item_number ))
    let total_purchase_price+=$item_total_price
    
    if [ -v customer_purchases[$item] ]
    then
        let customer_purchases["$item"]+=$item_number
    elif [ ! -v customer_purchases[$item] ]
    then
        let customer_purchases["$item"]=$item_number     
    fi

    echo -e "\nYour cart items:\n$(show_purchase ${!customer_purchases[*]})\n"

    show_total_price ${total_purchase_price}
    echo -e "###############\n"
}

# -- Export the factor --------------------------------------------
export_factor() {
    timestamp=$(date)
    echo -e "----- Factor for ${customer_name} At $timestamp ------\n" >> /home/$USER/factor.log
    discount "${total_purchase_price}" >> /home/$USER/factor.log
    show_purchase >> /home/$USER/factor.log
    echo -e "\n----- ########################## -----\n" >> /home/$USER/factor.log
}


# -- List shopping choices ----------------------------------------
show_menu() {
    goods["Quit"]=0
    echo -e "Please tell me what you need: \n"

    select option in ${!goods[*]}
    do
        case $option in 
        "Pen")
        purchase ${goods["Pen"]} "Pen"
        ;;

        "Notebook")
        purchase ${goods["Notebook"]} "Notebook"
        ;;

        "Pencil")
        purchase ${goods["Pencil"]} "Pencil"
        ;;

        "A4_paper")
        purchase ${goods["A4_paper"]} "A4_paper"
        ;;
            
        "Quit")
        if [[ $total_purchase_price -ne 0 ]]
        then
            export_factor 
            continue_shopping=0
            break
        else
            echo "Empty list!"
            continue_shopping=1
        fi
        ;;
        
        *)
        echo "Invalid option $REPLY."
        ;;
    
        esac
    done
}


# -- Repeat the procedure -----------------------------------------
while [[ continue_shopping -ne 0 ]]
do
    show_menu  
done


# -- Greet to goodbyte! -------------------------------------------
greeting "Have a brilliant day!"
exit 0