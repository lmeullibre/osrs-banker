<script lang="ts">
  import { onMount } from 'svelte';
  import selectedItemsData from '../../selected_items.json';

  type Item = {
    id: number;
    name: string;
    categories: string[];
    icon: string;
    quantity: number;
  }

  let selectedItems: Item[] = Object.values(selectedItemsData);
  const categoriesSet: Set<string> = new Set(selectedItems.flatMap(item => item.categories));
  let categories: string[] = Array.from(categoriesSet).sort();
  let selectedCategory: string = '';
  let selectedCategoriesList: string[] = [];

  function addToCategoryList() {
    if (selectedCategory && !selectedCategoriesList.includes(selectedCategory)) {
      selectedCategoriesList = [...selectedCategoriesList, selectedCategory];
      selectedCategory = '';
      sortItemsByCategories();
    }
  }

  function removeFromCategoryList(categoryToRemove: string) {
    selectedCategoriesList = selectedCategoriesList.filter(category => category !== categoryToRemove);
    sortItemsByCategories();
  }

  function sortItemsByCategories() {
    selectedItems = selectedItems.sort((item1, item2) => {
      const index1 = selectedCategoriesList.indexOf(item1.categories.find(category => selectedCategoriesList.includes(category)) || '');
      const index2 = selectedCategoriesList.indexOf(item2.categories.find(category => selectedCategoriesList.includes(category)) || '');

      if (index1 === -1 && index2 !== -1) return 1;
      if (index2 === -1 && index1 !== -1) return -1;

      if (index1 < index2) return -1;
      if (index1 > index2) return 1;

      // Sort by name within the same category group
      return item1.name.localeCompare(item2.name);
    });
  }
</script>

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
      <button on:click={() => removeFromCategoryList(selectedCategory)}>Remove</button>
    </li>
  {/each}
</ul>

<div class="grid grid-cols-8 gap-4">
  {#each selectedItems as item (item.id)}
    <div class="relative group">
      <img src={'data:image/png;base64,' + item.icon} alt={item.name} class="w-full h-full object-cover" />
      <div class="absolute top-0 right-0 bg-black bg-opacity-50 text-white px-1 rounded-bl-md">{item.quantity}</div>
      <div class="opacity-0 group-hover:opacity-100 absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center text-white text-sm">{item.name}</div>
    </div>
  {/each}
</div>
