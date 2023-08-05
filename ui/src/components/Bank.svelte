<script lang="ts">
  import { onMount } from "svelte";
  import selectedItemsData from "../../selected_items.json";
  import { initializeApp } from "firebase/app";
  import { get, getDatabase, ref, set } from "firebase/database";

  const searchParams = new URLSearchParams(window.location.search);
  const id = searchParams.get("id");

  console.log("MORENO", import.meta.env);

  const firebaseConfig = {
    apiKey: import.meta.env.VITE_APP_API_KEY,
    authDomain: "osrs-banker.firebaseapp.com",
    projectId: "osrs-banker",
    storageBucket: "osrs-banker.appspot.com",
    messagingSenderId: "218378048399",
    appId: import.meta.env.VITE_APP_ID,
    databaseURL: import.meta.env.VITE_DATABASE_URL,
  };
  const app = initializeApp(firebaseConfig);

  const database = getDatabase(app);

  type Item = {
    id: number;
    name: string;
    categories: string[];
    icon: string;
    quantity: number;
  };

  let selectedItems: Item[] = [];
  let categories: string[] = [];
  let selectedCategory: string = "";
  let selectedCategoriesList: string[] = [];

  function addToCategoryList() {
    if (
      selectedCategory &&
      !selectedCategoriesList.includes(selectedCategory)
    ) {
      selectedCategoriesList = [...selectedCategoriesList, selectedCategory];
      selectedCategory = "";
      sortItemsByCategories();
    }
  }

  function removeFromCategoryList(categoryToRemove: string) {
    selectedCategoriesList = selectedCategoriesList.filter(
      (category) => category !== categoryToRemove
    );
    sortItemsByCategories();
  }

  function sortItemsByCategories() {
    selectedItems = selectedItems.sort((item1, item2) => {
      const index1 = selectedCategoriesList.indexOf(
        item1.categories.find((category) =>
          selectedCategoriesList.includes(category)
        ) || ""
      );
      const index2 = selectedCategoriesList.indexOf(
        item2.categories.find((category) =>
          selectedCategoriesList.includes(category)
        ) || ""
      );

      if (index1 === -1 && index2 !== -1) return 1;
      if (index2 === -1 && index1 !== -1) return -1;

      if (index1 < index2) return -1;
      if (index1 > index2) return 1;

      // Sort by name within the same category group
      return item1.name.localeCompare(item2.name);
    });
  }

  onMount(async () => {
    if (id) {
      const itemRef = ref(database, "items/" + id);
      const snapshot = await get(itemRef);

      if (snapshot.exists()) {
        const itemData = snapshot.val();
        console.log(itemData);
        for (let item of Object.keys(itemData)) {
          const itemDetails = selectedItemsData[item];
          if (itemDetails) {
            selectedItems = [...selectedItems, itemDetails];
            categories = [...categories, ...itemDetails.categories];
          }
        }
        const categoriesSet: Set<string> = new Set(categories);
        categories = Array.from(categoriesSet).sort();
        console.log("hello", selectedItems);
      } else {
        console.log("No data available for this item id");
      }
    }
  });
</script>

<!-- svelte-ignore a11y-label-has-associated-control -->
<label>Select a category:</label>
<select bind:value={selectedCategory}>
  <option value="">-- select a category --</option>
  {#each categories as category (category)}
    <option value={category}>{category}</option>
  {/each}
</select>

<button on:click={addToCategoryList}>Add to list</button>

<h2>Selected Categories:</h2>
<ul>
  {#each selectedCategoriesList as selectedCategory (selectedCategory)}
    <li>
      {selectedCategory}
      <button on:click={() => removeFromCategoryList(selectedCategory)}
        >Remove</button
      >
    </li>
  {/each}
</ul>

<div class="grid grid-cols-8 gap-4">
  {#each selectedItems as item (item.id)}
    <div class="relative group">
      <img
        src={"data:image/png;base64," + item.icon}
        alt={item.name}
        class="w-full h-full object-cover"
      />
      <div
        class="absolute top-0 right-0 bg-black bg-opacity-50 text-white px-1 rounded-bl-md"
      >
        {item.quantity}
      </div>
      <div
        class="opacity-0 group-hover:opacity-100 absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center text-white text-sm"
      >
        {item.name}
      </div>
    </div>
  {/each}
</div>
